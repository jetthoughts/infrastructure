data "template_file" "ca_config" {
  template = "${file("${path.module}/data/openssl.tpl.cnf")}"

  vars {
    ip = "127.0.0.1"
  }
}

output "ca" {
  value = "${data.template_file.ca_config.rendered}"
}
