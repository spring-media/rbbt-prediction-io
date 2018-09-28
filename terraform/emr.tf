resource "aws_emr_cluster" "tf-predictionio-hbase" {
  name          = "emr-prediction-io-hbase"
  release_label = "emr-5.7.0"
  applications  = ["Hadoop", "HBase", "ZooKeeper"]

  ec2_attributes {
    subnet_id = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"

    emr_managed_master_security_group = "${aws_security_group.master_slave.id}"
    emr_managed_slave_security_group  = "${aws_security_group.master_slave.id}"
    instance_profile                  = "${aws_iam_instance_profile.emr_profile.arn}"
    key_name                          = "production-bootstrap"
    service_access_security_group     = "${aws_security_group.emr_service.id}"
  }

  master_instance_type = "m4.large"
  core_instance_type   = "m4.large"
  core_instance_count  = 1

  tags {
    Service     = "hbase-${local.domain_name}"
    Team        = "up"
    Environment = "production"
    Component   = "${local.domain_name}"
  }

  bootstrap_action {
    path = "s3://elasticmapreduce/bootstrap-actions/run-if"
    name = "runif"
    args = ["instance.isMaster=true", "echo running on master node"]
  }

  service_role = "${aws_iam_role.iam_emr_service_role.arn}"

  # lifecycle {
  #   ignore_changes = [
  #     "ec2_attributes.0.emr_managed_master_security_group",
  #     "ec2_attributes.0.emr_managed_slave_security_group",
  #     "ec2_attributes.0.service_access_security_group",
  #   ]
  # }
}

resource "aws_emr_cluster" "tf-predictionio-spark" {
  name                   = "emr-prediction-io-spark"
  release_label          = "emr-5.7.0"
  applications           = ["Spark"]
  termination_protection = false

  ec2_attributes {
    subnet_id = "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}"
    emr_managed_master_security_group = "${aws_security_group.master_slave.id}"
    emr_managed_slave_security_group  = "${aws_security_group.master_slave.id}"
    instance_profile                  = "${aws_iam_instance_profile.emr_profile.arn}"
    key_name                          = "production-bootstrap"
    service_access_security_group     = "${aws_security_group.emr_service.id}"
  }

  master_instance_type = "m4.large"
  core_instance_type   = "m4.large"
  core_instance_count  = 1

  tags {
    Service     = "spark-${local.domain_name}"
    Team        = "up"
    Environment = "production"
    Component   = "${local.domain_name}"
  }

  bootstrap_action {
    path = "s3://elasticmapreduce/bootstrap-actions/run-if"
    name = "runif"
    args = ["instance.isMaster=true", "echo running on master node"]
  }

  service_role = "${aws_iam_role.iam_emr_service_role.arn}"

  # lifecycle {
  #   ignore_changes = ["ec2_attributes.0.emr_managed_master_security_group",
  #     "ec2_attributes.0.emr_managed_slave_security_group",
  #     "ec2_attributes.0.service_access_security_group",
  #   ]
  # }
}

resource "aws_security_group" "master_slave" {
  name        = "emr_allow_all"
  description = "Allow all inbound traffic (EMR/Hbase/Spark/ES)"
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
    Name = "emr-spark-hbase-master-slave"
  }
}

resource "aws_security_group" "emr_service" {
  description = "EMR Security Group"
  vpc_id      = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"

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
    Name = "emr-service-access"
  }
}

###

# IAM Role setups

###

# IAM role for EMR Service
resource "aws_iam_role" "iam_emr_service_role" {
  name = "iam_emr_service_role"

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
resource "aws_iam_role_policy_attachment" "iam_emr_service_policy" {
  role       = "${aws_iam_role.iam_emr_service_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

# IAM Role for EC2 Instance Profile
resource "aws_iam_role" "iam_emr_profile_role" {
  name = "iam_emr_profile_role"

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

resource "aws_iam_instance_profile" "emr_profile" {
  name = "emr_profile"
  role = "${aws_iam_role.iam_emr_profile_role.name}"
}

# Default policy for the Amazon Elastic MapReduce for EC2 service role.
resource "aws_iam_role_policy_attachment" "iam_emr_profile_policy" {
  role       = "${aws_iam_role.iam_emr_profile_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}
