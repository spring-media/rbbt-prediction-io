resource "aws_alb_target_group" "internal_alb_target_group_ur" {
  name                 = "pio-ur-poc"
  port                 = "8000"
  protocol             = "HTTP"
  vpc_id               = "${data.aws_cloudformation_stack.vpc.outputs["VpcId"]}"
  deregistration_delay = 30

  health_check {
    path                = "/"
    protocol            = "HTTP"
    timeout             = "60"
    interval            = "120"
    healthy_threshold   = "2"
    unhealthy_threshold = "8"
    port                = "8000"
  }

  tags {
    Name        = "pio-ur-poc-alb"
    service     = "pio"
    component   = "pio"
    application = "pio"
    environment = "poc"
    team        = "up"
    managed_by  = "terraform"
  }
}

resource "aws_alb_listener_rule" "internal_alb_listener_rule_ur" {
  listener_arn = "${data.terraform_remote_state.alb.internal_alb_listener_id}"
  priority     = "147"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.internal_alb_target_group_ur.arn}"
  }

  condition {
    field = "host-header"

    values = [
      "${aws_route53_record.ur_internal.fqdn}",
    ]
  }
}

resource "aws_route53_record" "ur_internal" {
  name    = "pio-ur"
  type    = "A"
  zone_id = "Z17GPKRT9COZ3L"

  alias {
    evaluate_target_health = true
    name                   = "${data.terraform_remote_state.alb.internal_alb_dns_name}"
    zone_id                = "${data.terraform_remote_state.alb.internal_hosted_zone_id}"
  }
}

resource "aws_route53_record" "ur_external" {
  name    = "pio-ur"
  type    = "CNAME"
  zone_id = "Z2Y0RY5OG39VAR"
  ttl     = "60"
   records        = ["ecs-proxy-ecs-infrastructure.up.welt.de"]
}