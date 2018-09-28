resource "aws_elasticsearch_domain" "default" {
  domain_name           = "${local.domain_name}"
  elasticsearch_version = "5.5"

  cluster_config {
    instance_type            = "${local.instance_type}"
    dedicated_master_type    = "t2.small.elasticsearch"
    instance_count           = "${local.instance_count}"
    dedicated_master_count   = 1
    dedicated_master_enabled = false
    zone_awareness_enabled   = false
  }

  vpc_options {
    subnet_ids = [
      "${data.aws_cloudformation_stack.vpc.outputs["PrivateAlphaSubnetId"]}",
    ]

    security_group_ids = ["${aws_security_group.es.id}"]
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = "${local.storage_gb}"
  }

  tags {
    Domain      = "${local.domain_name}"
    Service     = "es-${local.domain_name}"
    Team        = "up"
    Environment = "production"
    Component   = "${local.domain_name}"
  }
}

data "aws_iam_policy_document" "es" {
  statement {
    actions = ["es:*"]

    resources = [
      "${aws_elasticsearch_domain.default.arn}",
      "${aws_elasticsearch_domain.default.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_elasticsearch_domain_policy" "es" {
  domain_name     = "${local.domain_name}"
  access_policies = "${data.aws_iam_policy_document.es.json}"
}

resource "aws_security_group" "es" {
  description = "ECS Security Group"
  vpc_id      = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"

  tags {
    Name       = "${local.domain_name}"
    product    = "up"
    managed_by = "terraform"
  }
}

resource "aws_security_group_rule" "es" {
  security_group_id        = "${aws_security_group.es.id}"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.es.id}"
  description              = "ECS to ElasticSearch (logs) access"
}