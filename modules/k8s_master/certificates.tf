module "certificates" {
  source       = "../k8s_certificates"
  name         = "${var.name}"
  certs_path   = "${var.certs_path}"
  kube_version = "${var.kube_version}"
}
