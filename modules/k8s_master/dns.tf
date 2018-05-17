resource "aws_route53_record" "api" {
  zone_id = "${var.dns_zone_id}"
  name    = "${local.domain}"
  type    = "A"
  ttl     = "300"
  records = "${var.master_addresses}"
}

resource "aws_route53_record" "internal" {
  zone_id = "${var.dns_zone_id}"
  name    = "${local.internal_domain}"
  type    = "A"
  ttl     = "300"
  records = "${var.master_addresses}"
}
