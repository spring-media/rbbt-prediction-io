data "aws_ami" "ec2_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  name_regex = "^amzn-ami-hvm-[\\d\\.]+-x86_64-gp2"
  owners     = ["amazon"]
}


resource "aws_launch_configuration" "pio" {
  name_prefix                 = "tf-pio"
  image_id                    = "${data.aws_ami.ec2_ami.id}"
  instance_type               = "m5.xlarge"
  user_data                   =  "${file("user_data.sh")}"
  key_name                    = "production-bootstrap"
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.this.id}"

  root_block_device {
    volume_size = "40"
    volume_type = "gp2"
    delete_on_termination = true
  }

  security_groups = [
    "${aws_security_group.allow_all.id}",
    "${aws_security_group.es.id}",
    # "${module.spark.service_sg_id}",
    "${module.hbase.service_sg_id}",
    "${data.aws_cloudformation_stack.environment.outputs["InstanceSecurityGroup"]}",
    "${data.aws_cloudformation_stack.vpc.outputs["VpcInstanceSecurityGroup"]}"
  ]

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "pio" {
  name                      = "pio"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 900
  health_check_type         = "ELB"

  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.pio.name}"
  default_cooldown          = 30

  termination_policies = [
    "OldestInstance",
    "OldestLaunchConfiguration",
  ]

  target_group_arns = [
    "${aws_alb_target_group.internal_alb_target_group_ur.arn}",
    "${aws_alb_target_group.internal_alb_target_group_es.arn}",
  ]

  vpc_zone_identifier = [
    "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}",
    "${data.aws_cloudformation_stack.vpc.outputs["PrivateBetaSubnetId"]}",
    "${data.aws_cloudformation_stack.vpc.outputs["PrivateGammaSubnetId"]}",
  ]

  tag {
    key                 = "Name"
    value               = "Pio"
    propagate_at_launch = true
  }

  tag {
    key                 = "component"
    value               = "pio"
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = "up"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "production"
    propagate_at_launch = true
  }

  tag {
    key                 = "managed_by"
    value               = "terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "service"
    value               = "pio"
    propagate_at_launch = true
  }
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

resource "aws_iam_role" "this" {
  name = "iam_pio_profile_role"
   assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
 resource "aws_iam_instance_profile" "this" {
  name = "pio_profile"
  role = "${aws_iam_role.this.name}"
}

data "aws_iam_policy_document" "pio_server" {
  "statement" {
    actions   = ["ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/service/frank/"]
  }
  "statement" {
    actions   = ["ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/service/piwik/rds/"]
  }
  "statement" {
    actions   = ["ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/service/pio/"]
  }
  "statement" {
    actions   = ["ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/slack/up-status/"]
  }
  statement {
    actions = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${local.region}:${local.account_id}:key/915d158f-48a1-4ad9-8705-a4ed812295e4"]
  }
  statement {
    actions = ["ecr:*"]
    resources = ["${aws_ecr_repository.repo.arn}"]
  }
  statement {
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "pio_server" {
  name   = "pio_server_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.pio_server.json}"
}

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = "${aws_iam_role.this.id}"
  policy_arn = "${aws_iam_policy.pio_server.arn}"
}
