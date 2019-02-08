module "certificates" {
  source       = "../k8s_certificates"
  name         = "${var.name}"
  certs_path   = "${var.certs_path}"
  kube_version = "${var.kube_version}"
  cert_sans    = "${join(",", concat(var.master_addresses, var.cert_sans, list("localhost", "127.0.0.1", "${local.domain}", "${local.internal_domain}") ))}"
}
