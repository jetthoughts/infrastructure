data "template_file" "node_join" {
  template = "${file("${path.module}/data/node_join.tpl.sh")}"

  vars {
    kube_version = "${var.kube_version}"
    kube_token   = "${var.k8s_token}"
    master_ip   = "${var.master_ip}"
    node_labels  = "${join(" ", var.node_labels)}"
  }
}

data "template_file" "kube_args" {
  template = "${file("${path.module}/data/k8s_kubelet_extra_args.tpl.sh")}"

  vars {
    node_labels  = "${join(",", var.node_labels)}"
    node_taints  = "${join(",", var.kube_node_taints)}"
  }
}

data "template_cloudinit_config" "node_init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "00pre.sh"
    content_type = "text/x-shellscript"
    content      = "${var.pre_init_script}"
  }

  part {
    filename     = "01packages.sh"
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/data/packages.sh")}"
  }

  part {
    filename     = "02kube_packages.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.kube_packages.rendered}"
  }

  part {
    filename     = "10node.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.node_join.rendered}"
  }

  part {
    filename     = "20kube_args.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.kube_args.rendered}"
  }

  part {
    filename     = "99reboot.sh"
    content_type = "text/x-shellscript"
    content      = "#!/usr/bin/env bash\n\ntouch /tmp/completed_user_data ; reboot\n"
  }
}

resource "aws_launch_configuration" "node" {
  depends_on           = ["aws_iam_role_policy.nodes"]
  name_prefix          = "k8s-${var.name}-${var.kube_version}-node-"
  image_id             = "${var.image_id}"
  user_data            = "${data.template_cloudinit_config.node_init.rendered}"
  instance_type        = "${var.instance_type}"
  spot_price           = "${var.spot_price}"
  key_name             = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes.id}"

  enable_monitoring = false

  security_groups = ["${var.security_groups}"]

  root_block_device = {
    volume_type           = "standard"
    volume_size           = 20
    delete_on_termination = true
    iops                  = 0
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Run instances
resource "aws_autoscaling_group" "node" {
  name = "k8s-${var.name}-node"

  availability_zones = [
    "${var.availability_zone}",
  ]

  vpc_zone_identifier = [
    "${var.subnet_id}",
  ]

  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  launch_configuration = "${aws_launch_configuration.node.name}"

  tags = ["${var.tags}"]
  target_group_arns = ["${var.target_group_arns}"]
}

data "template_file" "kube_packages" {
  template = "${file("${path.module}/data/kube_packages.tpl.sh")}"

  vars {
    kube_version = "${var.kube_version}"
  }
}
