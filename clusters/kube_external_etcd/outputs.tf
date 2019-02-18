output "domain" {
  value = "${module.k8s_master.domain[0]}"
}
