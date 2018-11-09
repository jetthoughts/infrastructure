resource "aws_route53_record" "api" {
  count = "${var.dns_zone_id == "" ? 0 : 1}"
  zone_id = "${var.dns_zone_id}"
  name    = "${local.domain}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = ["${aws_instance.masters.public_ip}"]
}

resource "aws_route53_record" "internal" {
  count = "${var.dns_zone_id == "" ? 0 : 1}"
  zone_id = "${var.dns_zone_id}"
  name    = "${local.internal_domain}"
  type    = "A"
  ttl     = "${var.dns_ttl}"
  records = "${var.master_addresses}"
}
