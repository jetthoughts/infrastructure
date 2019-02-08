resource "null_resource" "generate_pki" {
  triggers {
    cert_sans = "${var.cert_sans}"
    ca_exists = "${(length(data.local_file.missca.content) > 0 ? 1 : 0)}"
  }

  provisioner "local-exec" {
    command = "${path.module}/data/generate.sh ${var.name} ${var.kube_version} ${var.certs_path} '${var.cert_sans}'"
  }
}

data "local_file" "ca" {
  filename = "${var.certs_path}/pki/ca.crt"
  depends_on = ["null_resource.generate_pki"]
}

data "local_file" "missca" {
  filename = "${var.certs_path}/pki/ca.crt"
}

data "external" "certs" {
  program = ["ruby", "${path.module}/data/cert_exists.rb"]

  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    id = "abc123"
  }
}

resource "null_resource" "extract_admin_key" {
  depends_on = ["null_resource.generate_pki"]

  triggers {
    policy_sha1 = "${sha1(data.local_file.ca.content)}"
  }

  provisioner "local-exec" {
    command = "ruby ${path.module}/data/extract_crt.rb -s ${var.certs_path}/admin.conf -d ${var.certs_path}"
  }
}
