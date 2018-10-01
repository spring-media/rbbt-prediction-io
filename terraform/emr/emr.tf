resource "aws_emr_cluster" "this" {
  name          = "emr-prediction-io-hbase"
  release_label = "${var.release_label}"
  applications  = "${var.applications}"

  ec2_attributes {
    subnet_id = "${var.subnet_id}"

    emr_managed_master_security_group = "${aws_security_group.master.id}"
    emr_managed_slave_security_group  = "${aws_security_group.slave.id}"
    instance_profile                  = "${var.instance_profile}"
    key_name                          = "production-bootstrap"
    service_access_security_group     = "${aws_security_group.service.id}"
  }

  master_instance_type = "${var.master_instance_type}"
  core_instance_type   = "${var.core_instance_type}"
  core_instance_count  = "${var.core_instance_count}"

  tags {
    Service     = "pio-${var.service_name}"
    Team        = "up"
    Environment = "production"
    Component   = "pio-${var.service_name}"
  }

  bootstrap_action {
    path = "s3://elasticmapreduce/bootstrap-actions/run-if"
    name = "runif"
    args = ["instance.isMaster=true", "echo running on master node"]
  }

  service_role = "${aws_iam_role.this.arn}"
}

resource "aws_route53_record" "this" {
  zone_id = "Z17GPKRT9COZ3L"
  name    = "pio-${var.service_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_emr_cluster.this.master_public_dns}"]
}

resource "aws_security_group" "master" {
  name        = "tf-emr-pio-${var.service_name}-master"
  description = "Allow all inbound traffic (EMR/Hbase/Spark/ES)"
  vpc_id      = "${var.vpc_id}"

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
    Name = "emr-spark-hbase-master-slave"
  }
}

resource "aws_security_group" "slave" {
  name        = "tf-emr-pio-${var.service_name}-slave"
  description = "Allow all inbound traffic (EMR/Hbase/Spark/ES)"
  vpc_id      = "${var.vpc_id}"

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
    Name = "emr-spark-hbase-master-slave"
  }
}

resource "aws_security_group" "service" {
  description = "tf-emr-pio-${var.service_name}-service"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "tf-emr-pio-${var.service_name}-service"
  }
}

###

# IAM Role setups

###

# IAM role for EMR Service
resource "aws_iam_role" "this" {
  name = "tf-emr-pio-${var.service_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Default policy for the Amazon Elastic MapReduce service role.
resource "aws_iam_role_policy_attachment" "this" {
  role       = "${aws_iam_role.this.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}