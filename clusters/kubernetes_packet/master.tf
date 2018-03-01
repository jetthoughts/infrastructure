resource "packet_device" "masters" {
  count         = "${var.cluster_size}"
  hostname      = "master"
  billing_cycle = "hourly"
  project_id    = "${packet_project.k8s_dev.id}"

  // https://www.packet.net/developers/api/facilities/
  facility = "ewr1"

  // https://www.packet.net/developers/api/operatingsystems/
  operating_system = "centos_7"

  // https://www.packet.net/developers/api/plans/
  plan = "baremetal_0"

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("${path.module}/assets/k8s")}"
    host        = "${self.network.0.address}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/terraform/pki",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/data/packages.sh"
    destination = "/tmp/terraform/packages.sh"
  }

  provisioner "file" {
    source      = "${path.module}/data/disable_swap.sh"
    destination = "/tmp/terraform/disable_swap.sh"
  }

  provisioner "file" {
    source      = "${path.module}/data/k8s_kubelet_extra_args.sh"
    destination = "/tmp/terraform/k8s_kubelet_extra_args.sh"
  }

  provisioner "file" {
    source      = "${path.module}/data/certificates.sh"
    destination = "/tmp/terraform/certificates.sh"
  }

  provisioner "file" {
    source      = "${var.certs_path}/"
    destination = "/tmp/terraform/pki"
  }

  provisioner "file" {
    content     = "${data.template_file.kubeadm_config.rendered}"
    destination = "/tmp/terraform/kubeadm_config.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.master_user_data.rendered}"
    destination = "/tmp/terraform/master.sh"
  }

  provisioner "file" {
    content = <<EOF
  set -x
  kubectl --kubeconfig=/etc/kubernetes/admin.conf create clusterrolebinding cluster-admin-${var.admin_email} --clusterrole=cluster-admin --user=${var.admin_email} || true
  kubectl --kubeconfig=/etc/kubernetes/admin.conf create clusterrolebinding admin-${var.admin_email} --clusterrole=admin --user=${var.admin_email} || true
  EOF

    destination = "/tmp/terraform/admin.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/terraform/*.sh",
      "sudo /tmp/terraform/packages.sh",
      "sudo /tmp/terraform/disable_swap.sh",
      "sudo /tmp/terraform/k8s_kubelet_extra_args.sh",
      "sudo cat /etc/fstab",
      "sudo /tmp/terraform/certificates.sh",
      "sudo /tmp/terraform/kubeadm_config.sh",
      "sudo cat /etc/kubernetes/kubeadm.yml",
      "sudo /tmp/terraform/master.sh",
      "sudo sh /tmp/terraform/admin.sh",
      "sudo reboot",
    ]
  }
}

data "template_file" "master_user_data" {
  template = "${file("${path.module}/data/master_init.tpl.sh")}"

  vars {
    k8s_token              = "${var.k8s_token}"
    k8s_version            = "${var.k8s_version}"
    k8s_pod_network_cidr   = "${var.k8s_pod_network_cidr}"
    domain                 = "${var.domain}"
    google_oauth_client_id = "${var.google_oauth_client_id}"
    ca_crt                 = "${var.k8s_ca_crt}"
    master_ips             = "${join("\" \"", var.master_addresses)}"
    etcd_endpoints         = "${join("\" \"", var.etcd_endpoints)}"
  }
}

data "template_file" "kubeadm_config" {
  template = "${file("${path.module}/data/kubeadm_config.tpl.sh")}"

  vars {
    k8s_token              = "${var.k8s_token}"
    k8s_version            = "${var.k8s_version}"
    k8s_pod_network_cidr   = "${var.k8s_pod_network_cidr}"
    domain                 = "${var.domain}"
    google_oauth_client_id = "${var.google_oauth_client_id}"
    cluster_size           = "${var.cluster_size}"
    master_ips             = "${join("\" \"", concat(var.master_addresses, var.cert_sans))}"
    etcd_endpoints         = "${join("\" \"", var.etcd_endpoints)}"
  }
}
