locals {
  ec2_tags        = "${merge(map("Name", "k8s_${var.name}_master", "KubernetesCluster", "${var.name}", "kubernetes.io/cluster/${var.name}", "true"),var.tags)}"
  pki_path        = "${var.certs_path}/pki/"
  domain          = "api.${var.name}.${var.datacenter}.${var.dns_primary_domain}"
  internal_domain = "internal.${var.name}.${var.datacenter}.${var.dns_primary_domain}"
}

resource "aws_instance" "masters" {
  count = "${var.cluster_size}"

  depends_on = [
    "aws_iam_role_policy.masters",
    "module.certificates",
    "aws_route53_record.internal",
    "aws_route53_record.api",
  ]

  ami           = "${var.image_id}"
  instance_type = "${var.instance_type}"

  key_name             = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.masters.id}"
  monitoring           = false

  vpc_security_group_ids = [
    "${var.security_groups}",
  ]

  availability_zone       = "${var.availability_zone}"
  subnet_id               = "${var.subnet_id}"
  private_ip              = "${element(var.master_addresses, count.index)}"
  disable_api_termination = false

  root_block_device = {
    volume_type           = "standard"
    volume_size           = 8
    delete_on_termination = true
    iops                  = 0
  }

  tags        = "${local.ec2_tags}"
  volume_tags = "${local.ec2_tags}"
}


resource "null_resource" "bootstrap_bastion" {
  count = "${var.bastion["host"] == "" ? 0 : var.cluster_size}"

  connection {
    host                = "${element(aws_instance.masters.*.private_ip, count.index)}"
    user                = "${var.remote_user}"
    private_key         = "${file("${var.asset_path}/${var.ssh_key_name}")}"
    bastion_host        = "${var.bastion["host"]}"
    bastion_user        = "${var.bastion["user"]}"
    bastion_port        = "${var.bastion["port"]}"
    bastion_private_key = "${var.bastion["private_key"]}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/terraform/pki",
    ]
  }

  provisioner "file" {
    content     = "${var.pre_init_script}"
    destination = "/tmp/terraform/00pre_init_script.sh"
  }

  provisioner "file" {
    source      = "${path.module}/data/packages.sh"
    destination = "/tmp/terraform/packages.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.kube_packages.rendered}"
    destination = "/tmp/terraform/kube_packages.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.kube_args.rendered}"
    destination = "/tmp/terraform/k8s_kubelet_extra_args.sh"
  }

  provisioner "file" {
    source      = "${path.module}/data/certificates.sh"
    destination = "/tmp/terraform/certificates.sh"
  }

  provisioner "file" {
    source      = "${local.pki_path}/"
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
      "sudo /tmp/terraform/00pre_init_script.sh",
      "sudo /tmp/terraform/packages.sh",
      "sudo /tmp/terraform/kube_packages.sh",
      "sudo /tmp/terraform/k8s_kubelet_extra_args.sh",
      "sudo /tmp/terraform/certificates.sh",
      "sudo /tmp/terraform/kubeadm_config.sh",
      "sudo /tmp/terraform/master.sh",
      "sudo sh /tmp/terraform/admin.sh",
      "sudo shutdown -r +1",
    ]
  }
}

resource "null_resource" "bootstrap_public" {
  count = "${var.bastion["host"] == "" ? var.cluster_size : 0}"

  connection {
    host                = "${element(aws_instance.masters.*.public_ip, count.index)}"
    user                = "${var.remote_user}"
    private_key         = "${file("${var.asset_path}/${var.ssh_key_name}")}"
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
    content     = "${data.template_file.kube_packages.rendered}"
    destination = "/tmp/terraform/kube_packages.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.kube_args.rendered}"
    destination = "/tmp/terraform/k8s_kubelet_extra_args.sh"
  }

  provisioner "file" {
    source      = "${path.module}/data/certificates.sh"
    destination = "/tmp/terraform/certificates.sh"
  }

  provisioner "file" {
    source      = "${local.pki_path}/"
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
      "sudo /tmp/terraform/kube_packages.sh",
      "sudo /tmp/terraform/k8s_kubelet_extra_args.sh",
      "sudo /tmp/terraform/certificates.sh",
      "sudo /tmp/terraform/kubeadm_config.sh",
      "sudo /tmp/terraform/master.sh",
      "sudo sh /tmp/terraform/admin.sh",
      "sudo shutdown -r +1",
    ]
  }
}


data "template_file" "master_user_data" {
  template = "${file("${path.module}/data/master_init.tpl.sh")}"

  vars {
    k8s_token              = "${var.k8s_token}"
    k8s_version            = "${var.kube_version}"
    k8s_pod_network_cidr   = "${var.k8s_pod_network_cidr}"
    domain                 = "api.${var.name}.${var.datacenter}.${var.dns_primary_domain}"
    google_oauth_client_id = "${var.google_oauth_client_id}"
    ca_crt                 = "${var.k8s_ca_crt}"
    master_ips             = "\"${join("\" \"", var.master_addresses)}\""
    etcd_endpoints         = "\"${join("\" \"", var.etcd_endpoints)}\""
  }
}

data "template_file" "kubeadm_config" {
  template = "${file("${path.module}/data/kubeadm_config.tpl.sh")}"

  vars {
    k8s_token              = "${var.k8s_token}"
    kube_version           = "${var.kube_version}"
    k8s_pod_network_cidr   = "${var.k8s_pod_network_cidr}"
    domain                 = "${local.domain}"
    google_oauth_client_id = "${var.google_oauth_client_id}"
    cluster_size           = "${var.cluster_size}"
    master_ips             = "\"${join("\" \"", concat(var.master_addresses, var.cert_sans))}\""
    etcd_endpoints         = "\"${join("\" \"", var.etcd_endpoints)}\""
    etcd_prefix            = "${var.etcd_prefix}"
  }
}

data "template_file" "kube_packages" {
  template = "${file("${path.module}/data/kube_packages.tpl.sh")}"

  vars {
    kube_version = "${var.kube_version}"
  }
}

data "template_file" "kube_args" {
  template = "${file("${path.module}/data/k8s_kubelet_extra_args.tpl.sh")}"

  vars {
    kubelet_extra_args = "${join(" ", var.kubelet_extra_args)}"
  }
}
