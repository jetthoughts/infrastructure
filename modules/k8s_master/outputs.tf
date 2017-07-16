output "domain" {
  value = "${aws_route53_record.api.fqdn}"
}

output "master_ip" {
  value = "${data.aws_instance.master.private_ip}"
}

output "user_data" {
  value = "${data.template_cloudinit_config.master-init.rendered}"
}
