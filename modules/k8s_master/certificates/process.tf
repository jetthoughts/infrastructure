resource "null_resource" "generate_pki" {
  provisioner "local-exec" {
    command = "${path.module}/data/generate.sh ${var.kube_version} ${var.certs_path} '${var.cert_sans}'"
  }
}
