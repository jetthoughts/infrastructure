resource "aws_route53_record" "api" {
  zone_id = "${var.dns_zone_id}"
  name    = "api.${var.name}.${var.datacenter}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.masters.*.private_ip}"]
}

resource "aws_route53_record" "internal" {
  zone_id = "${var.dns_zone_id}"
  name    = "internal.${var.name}.${var.datacenter}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.masters.*.private_ip}"]
}
