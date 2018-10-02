###

# IAM Role setups

###

# IAM Role for EC2 Instance Profile
resource "aws_iam_role" "this" {
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
data "aws_iam_policy_document" "ecs_task_policy_doc" {
  "statement" {
    actions   = ["ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.environment}:${data.aws_caller_identity.current.account_id}:parameter/service/frank/"]
  }
  "statement" {
    actions   = ["ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.environment}:${data.aws_caller_identity.current.account_id}:parameter/service/piwik/"]
  }
  "statement" {
    actions   = ["ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.environment}:${data.aws_caller_identity.current.account_id}:parameter/service/pio/"]
  }
  statement {
    actions = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${local.environment}:${data.aws_caller_identity.current.account_id}:key/915d158f-48a1-4ad9-8705-a4ed812295e4"]
  }
  statement {
    actions = ["ecr:*"]
    resources = ["${aws_ecr_repository.repo.arn}"]
  }
}

resource "aws_iam_policy" "ssm" {
  name   = "ssm_pio_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ecs_task_policy_doc.json}"
}

resource "aws_iam_instance_profile" "this" {
  name = "emr_profile"
  role = "${aws_iam_role.this.name}"
}

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = "${aws_iam_role.this.id}"
  policy_arn = "${aws_iam_policy.ssm.arn}"
}

# Default policy for the Amazon Elastic MapReduce for EC2 service role.
resource "aws_iam_role_policy_attachment" "this" {
  role       = "${aws_iam_role.this.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}