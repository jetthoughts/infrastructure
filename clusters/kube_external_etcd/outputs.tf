output "domain" {
  value = "${module.k8s_master.domain[0]}"
}

output "internal" {
  value = "${module.k8s_master.internal_domain[0]}"
}
