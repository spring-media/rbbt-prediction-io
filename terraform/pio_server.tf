data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "server" {
  ami                  = "${data.aws_ami.ubuntu.id}"
  instance_type        = "t2.small"
  key_name             = "production-bootstrap"
  subnet_id            = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"
  iam_instance_profile = "${aws_iam_instance_profile.this.id}"
  user_data            = "${file("user_data.sh")}"

  # sg-1c0f7f7b up-production-ireland-bastion-host 
  security_groups = [
    "${aws_security_group.allow_all.id}",
    "${aws_security_group.es.id}",
    # "${module.spark.service_sg_id}",
    "${module.hbase.service_sg_id}",
  ]

  tags {
    Domain      = "${local.domain_name}"
    Service     = "pio-${local.domain_name}"
    Team        = "up"
    Environment = "production"
    Component   = "${local.domain_name}"
    Name        = "prediction-io"
  }

  # lifecycle {
  #     ignore_changes = ["security_groups"]
  # }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    name = "emr-pio-server-allow-all"
  }
}
