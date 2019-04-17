output "domain" {
  value = "${aws_route53_record.api.fqdn}"
}

output "master_ip" {
  value = "${aws_instance.masters.*.private_ip}"
}

output "internal_domain" {
  value = "${aws_route53_record.internal.*.fqdn}"
}
