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

resource "aws_iam_instance_profile" "this" {
  name = "emr_profile"
  role = "${aws_iam_role.this.name}"
}

# Default policy for the Amazon Elastic MapReduce for EC2 service role.
resource "aws_iam_role_policy_attachment" "this" {
  role       = "${aws_iam_role.this.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}