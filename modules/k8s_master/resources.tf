locals {
  ec2_tags = "${merge(map("Name", format("k8s_%s_master", var.name), "KubernetesCluster", "${var.name}", "kubernetes.io/cluster/${var.name}", "true"), var.tags)}"
  pki_path = "${var.certs_path}/pki/"

  base_domain     = "${var.name}.${var.dns_primary_domain}"
  domain          = "api.${local.base_domain}"
  internal_domain = "internal.${local.base_domain}"

  cluster_size = "${length(var.master_addresses)}"
}

resource "aws_instance" "masters" {
  count = "${local.cluster_size}"

  depends_on = [
    "aws_iam_role_policy.masters",
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
  depends_on = [
    "aws_instance.masters",
    "aws_route53_record.internal",
  ]

  count = "${var.bastion["host"] == "" ? 0 : local.cluster_size}"

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
    content     = "${data.template_file.master_init.rendered}"
    destination = "/tmp/terraform/master.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.cni.rendered}"
    destination = "/tmp/terraform/cni.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.admin.rendered}"
    destination = "/tmp/terraform/admin.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/terraform/*.sh",
      "sudo /tmp/terraform/00pre_init_script.sh",
      "sudo /tmp/terraform/packages.sh",
      "sudo /tmp/terraform/kube_packages.sh",

      # "sudo /tmp/terraform/k8s_kubelet_extra_args.sh",
      "sudo /tmp/terraform/certificates.sh",
    ]

    #     "sudo /tmp/terraform/kubeadm_config.sh",
    #     "sudo /tmp/terraform/master.sh || exit",
    #     "sudo /tmp/terraform/cni.sh",
    #     "sudo /tmp/terraform/admin.sh",
    #     "sudo shutdown -r +1",
  }
}

resource "null_resource" "bootstrap_public" {
  count = "${var.bastion["host"] == "" ? local.cluster_size : 0}"

  depends_on = [
    "aws_route53_record.internal",
    "module.certificates",
  ]

  triggers {
    cluster_instance = "${aws_instance.masters.*.id[count.index]}"
  }

  connection {
    host        = "${aws_instance.masters.*.public_ip[count.index]}"
    user        = "${var.remote_user}"
    private_key = "${file("${var.asset_path}/${var.ssh_key_name}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/terraform/pki",
    ]
  }

  provisioner "file" {
    source      = "${local.pki_path}/"
    destination = "/tmp/terraform/pki"
  }

  provisioner "file" {
    content     = "${var.pre_init_script}"
    destination = "/tmp/terraform/pre_init_script.sh"
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
    content     = "${data.template_file.kubeadm_config.rendered}"
    destination = "/tmp/terraform/kubeadm_config.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.master_init.rendered}"
    destination = "/tmp/terraform/master.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.cni.rendered}"
    destination = "/tmp/terraform/cni.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.admin.rendered}"
    destination = "/tmp/terraform/admin.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/terraform/*.sh",
      "sudo /tmp/terraform/pre_init_script.sh",
      "sudo /tmp/terraform/packages.sh",
      "sudo /tmp/terraform/kube_packages.sh",

      # "sudo /tmp/terraform/k8s_kubelet_extra_args.sh",
      "sudo /tmp/terraform/certificates.sh",

      "sudo /tmp/terraform/kubeadm_config.sh",
      "sudo /tmp/terraform/master.sh || exit",
      "sudo /tmp/terraform/cni.sh",
      "sudo /tmp/terraform/admin.sh || true",
      "sudo shutdown -r +1",
    ]
  }
}

data "template_file" "master_init" {
  template = "${file("${path.module}/data/master_init.tpl.sh")}"

  vars {
    kube_version            = "${var.kube_version}"
    domain                  = "${local.internal_domain}"
    kubeadm_bootstrap_token = "${var.bootstrap_token}"
    # etcd_endpoints          = "${join(":2379,", var.master_addresses)}:2379"
  }
}

data "template_file" "kubeadm_config" {
  template = "${file("${path.module}/data/kubeadm_config.tpl.sh")}"

  vars {
    name                   = "${var.name}"
    bootstrap_token        = "${var.bootstrap_token}"
    kube_version           = "${var.kube_version}"
    pod_network_cidr       = "${var.pod_network_cidr}"
    service_network_cidr   = "${var.service_network_cidr}"
    domain                 = "${local.domain}"
    internal_domain        = "${local.internal_domain}"
    google_oauth_client_id = "${var.google_oauth_client_id}"
    cluster_size           = "${local.cluster_size}"
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

data "template_file" "admin" {
  template = "${file("${path.module}/data/admin.tpl.sh")}"

  vars {
    admin_email = "${var.admin_email}"
  }
}

data "template_file" "cni" {
  template = "${file("${path.module}/data/cni.tpl.sh")}"

  vars {
    cni_install_script = "${var.cni_install_script}"
  }
}
