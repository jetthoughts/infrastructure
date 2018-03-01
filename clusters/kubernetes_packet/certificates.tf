locals {
  name           = "v19"
//  master_address = "${packet_device.masters.0.network.0.address}"
  master_address = "${var.domain}"
}

module "master_certificate" {
  source = "../../modules/certificates"
  name   = "${local.name}"

  host_connection = {
    type        = "ssh"
    user        = "root"
    private_key = "${path.module}/assets/k8s"
    host        = "${local.master_address}"
  }

  kube_conf_remote_path = "/root"
  asset_path            = "${path.module}/assets"
}

// Copy the keys to folder for multi master solution
resource "null_resource" "copy-pki" {
  depends_on = ["module.master_certificate"]
  provisioner "local-exec" {
    command = <<CMD
      cp -r ${var.asset_path}/${local.name}/kubernetes/pki/* ${var.certs_path}
CMD
  }
}

// Updated Kubectl config to access the cluster
resource "null_resource" "set-context" {
  depends_on = ["module.master_certificate"]
  provisioner "local-exec" {
    command = <<CMD
      kubectl config set-cluster ${local.name} --server="https://${local.master_address}:6443" --certificate-authority=${var.asset_path}/${local.name}/ca.crt --embed-certs=true
      kubectl config set-context ${var.admin_email}@${local.master_address} --cluster="${local.name}" --user="${var.admin_email}" --namespace=default
CMD
  }
}
