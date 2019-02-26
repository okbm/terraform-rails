# route53, alb, acm
resource "aws_route53_zone" "primary" {
  name = "${var.aws_web_domain}"
}

# httpの場合はこれで
# resource "aws_route53_record" "www" {
#   zone_id = "${aws_route53_zone.primary.zone_id}"
#   name    = "${var.aws_web_domain}"
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_eip.web.public_ip}"]
# }

resource "aws_route53_record" "wozz-jp-A" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.aws_web_domain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_alb" "alb" {
  name                       = "${var.name}"
  security_groups            = ["${aws_security_group.app.id}"]
  subnets                    = ["${aws_subnet.public_web.id}"]
  subnets                    = ["${aws_subnet.public_https.id}"]
  internal                   = false
  enable_deletion_protection = false
}

resource "aws_alb_target_group" "alb" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    interval            = 300
    path                = "/okcomputek"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_target_group_attachment" "alb" {
  target_group_arn = "${aws_alb_target_group.alb.arn}"
  target_id        = "${aws_instance.web.id}"
  port             = 80
}

# http
resource "aws_alb_listener" "alb_http_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb.arn}"
    type             = "forward"
  }
}
# https
resource "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb.arn}"
    type             = "forward"
  }
}

# resource "aws_elb" "elb" {
#   name    = "{var.name}"
#
#   security_groups = ["${aws_security_group.app.id}"]
#
#   listener {
#     instance_port     = 80
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }
#
#   listener {
#     instance_port     = 80
#     instance_protocol = "http"
#     lb_port           = 443
#     lb_protocol       = "https"
#     ssl_certificate_id = "${aws_acm_certificate.cert.arn}"
#   }
#
#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     target              = "HTTP:80/"
#     interval            = 300
#   }
#
#   instances                   = ["${aws_instance.web.id}"]
# }

resource "aws_acm_certificate" "cert" {
  domain_name               = "${var.aws_web_domain}"
  validation_method         = "DNS"
}
