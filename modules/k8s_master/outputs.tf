output "domain" {
  value = "${aws_route53_record.api.fqdn}"
}

output "master_ip" {
  value = "${aws_instance.masters.*.private_ip}"
}
