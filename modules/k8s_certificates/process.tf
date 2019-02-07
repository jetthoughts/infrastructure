resource "null_resource" "generate_pki" {
  triggers {
    cert_sans = "${var.cert_sans}"
  }

  provisioner "local-exec" {
    command = "${path.module}/data/generate.sh ${var.name} ${var.kube_version} ${var.certs_path} '${var.cert_sans}'"
  }
}

resource "null_resource" "extract_admin_key" {
  depends_on = ["null_resource.generate_pki"]

  triggers {
    policy_sha1 = "${sha1(file("${var.certs_path}/pki/ca.crt"))}"
  }

  provisioner "local-exec" {
    command = "ruby ${path.module}/data/extract_crt.rb -s ${var.certs_path}/admin.conf -d ${var.certs_path}"
  }
}
