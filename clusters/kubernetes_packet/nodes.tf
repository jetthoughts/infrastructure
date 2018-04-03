locals {
  master_private_address = "${packet_device.masters.0.network.2.address}"
}


resource "packet_device" "nodes" {
  count = "${var.nodes_count}"
  hostname = "node${count.index}"
  billing_cycle = "hourly"
  project_id = "${packet_project.k8s_dev.id}"

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
    source      = "${path.module}/data/kernel4.sh"
    destination = "/tmp/terraform/kernel4.sh"
  }

  provisioner "file" {
    source      = "${path.module}/data/packages.sh"
    destination = "/tmp/terraform/packages.sh"
  }

  provisioner "file" {
    destination = "/tmp/terraform/pre_init_script.sh"
    content      = <<EOF
      set -x
      "${var.pre_init_script}"
  EOF
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
    content      = "${data.template_file.node_join.rendered}"
    destination = "/tmp/terraform/node.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/terraform/*.sh",
      "sudo /tmp/terraform/kernel4.sh",
      "sudo /tmp/terraform/packages.sh",
      "sudo /tmp/terraform/pre_init_script.sh",
      "sudo /tmp/terraform/disable_swap.sh",
      "sudo /tmp/terraform/k8s_kubelet_extra_args.sh",
      "sudo cat /etc/fstab",
      "sudo /tmp/terraform/node.sh",
      "sudo reboot",
    ]
  }
}

data "template_file" "node_join" {
  template = "${file("${path.module}/data/node_join.tpl.sh")}"

  vars {
    k8s_token   = "${var.k8s_token}"
    k8s_version = "${var.k8s_version}"
    master_ip   = "${local.master_private_address}"
    labels      = "${join(" ", var.node_labels)}"
  }
}
