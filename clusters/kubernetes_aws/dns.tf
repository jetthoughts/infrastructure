resource "aws_route53_zone" "kb" {
  name = "kb.${var.domain}"

  tags {
    Terrform = "true"
  }
}

resource "aws_route53_record" "api_virginia_internal" {
  zone_id = "${aws_route53_zone.kb.zone_id}"
  name    = "api.internal.virginia"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instance.master.private_ip}"]
}

resource "aws_route53_record" "api_virginia_public" {
  zone_id = "${aws_route53_zone.kb.zone_id}"
  name    = "api.virginia"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instance.master.public_ip}"]
}

resource "aws_route53_record" "ui_virginia_public" {
  zone_id = "${aws_route53_zone.kb.zone_id}"
  name    = "ui.virginia"
  type    = "A"
  ttl     = "300"
  records = ["34.207.96.54"]
}

resource "aws_route53_record" "api_virginia" {
  zone_id = "${aws_route53_zone.kb.zone_id}"
  name    = "virginia"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instance.master.public_ip}"]
}

output "domain" {
  value = "${aws_route53_record.api_virginia.fqdn}"
}

output "ui" {
  value = "https://${aws_route53_record.api_virginia_internal.fqdn}:6443"
}
