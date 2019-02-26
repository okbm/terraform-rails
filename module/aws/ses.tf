resource "aws_ses_domain_identity" "ses" {
  domain = "${var.aws_web_domain}"
  provider = "aws.west"
}

resource "aws_route53_record" "ses_record" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "_amazonses.${aws_route53_zone.primary.name}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.ses.verification_token}"]
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = "${var.aws_web_domain}"
  provider = "aws.west"
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${aws_route53_zone.primary.name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
