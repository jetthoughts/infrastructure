resource "null_resource" "generate_pki" {
  triggers {
    ca_exists = "${data.external.cert_exists.result.exists}"
  }

  provisioner "local-exec" {
    command = "${path.module}/data/generate.sh ${var.name} ${var.kube_version} ${var.certs_path}"
  }
}

data "local_file" "ca" {
  filename   = "${var.certs_path}/pki/ca.crt"
  depends_on = ["null_resource.generate_pki"]
}

data "external" "cert_exists" {
  program = ["ruby", "${path.module}/data/exists_path.rb"]

  query = {
    path = "${var.certs_path}/pki/ca.crt"
  }
}

resource "null_resource" "extract_admin_key" {
  depends_on = ["null_resource.generate_pki"]

  provisioner "local-exec" {
    command = "ruby ${path.module}/data/extract_crt.rb -s ${var.certs_path}/admin.conf -d ${var.certs_path}"
  }
}
