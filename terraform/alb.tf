resource "aws_alb_target_group" "external_alb_target_group_ur" {
  name                 = "pio-ur-${local.environment}"
  port                 = "8000"
  protocol             = "HTTP"
  vpc_id               = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
  deregistration_delay = 30

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = "15"
    interval            = "30"
    healthy_threshold   = "2"
    unhealthy_threshold = "8"
    port                = "8000"
  }

  tags {
    Name        = "pio-${local.environment}-alb"
    service     = "pio"
    component   = "pio"
    application = "pio"
    environment = "${local.environment}"
    team        = "up"
    managed_by  = "terraform"
  }
}

resource "aws_alb_listener_rule" "external_alb_listener_rule_ur" {
  listener_arn = "${data.terraform_remote_state.alb.external_alb_listener_id}"
  priority     = "147"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.external_alb_target_group_ur.arn}"
  }

  condition {
    field = "host-header"

    values = [
      "${aws_route53_record.external_alb_dns_alias.fqdn}",
    ]
  }
}



resource "aws_alb_target_group" "external_alb_target_group" {
  name                 = "pio-${local.environment}"
  port                 = "7070"
  protocol             = "HTTP"
  vpc_id               = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
  deregistration_delay = 30

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = "15"
    interval            = "30"
    healthy_threshold   = "2"
    unhealthy_threshold = "8"
    port                = "7070"
  }

  tags {
    Name        = "pio-${local.environment}-alb"
    service     = "pio"
    component   = "pio"
    application = "pio"
    environment = "${local.environment}"
    team        = "up"
    managed_by  = "terraform"
  }
}

resource "aws_alb_listener_rule" "external_alb_listener_rule" {
  listener_arn = "${data.terraform_remote_state.alb.external_alb_listener_id}"
  priority     = "148"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.external_alb_target_group.arn}"
  }

  condition {
    field = "host-header"

    values = [
      "${aws_route53_record.external_alb_dns_alias.fqdn}",
    ]
  }
}

resource "aws_route53_record" "external_alb_dns_alias" {
  name    = "pio"
  type    = "A"
  zone_id = "Z2Y0RY5OG39VAR"

  alias {
    evaluate_target_health = true
    name                   = "${data.terraform_remote_state.alb.external_alb_dns_name}"
    zone_id                = "${data.terraform_remote_state.alb.external_hosted_zone_id}"
  }
}
