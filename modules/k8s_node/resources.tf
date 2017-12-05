data "template_file" "node_join" {
  template = "${file("${path.module}/data/node_join.tpl.sh")}"

  vars {
    k8s_token   = "${var.k8s_token}"
    k8s_version = "${var.k8s_version}"
    master_ip   = "${var.master_ip}"
    labels      = "${join(" ", var.node_labels)}"
  }
}

data "template_cloudinit_config" "node-init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "00pre.sh"
    content_type = "text/x-shellscript"
    content      = "${var.pre_init_script}"
  }

  part {
    filename     = "01node.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.node_join.rendered}"
  }

  part {
    filename     = "02ks8_args.sh"
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/data/k8s_kubelet_extra_args.sh")}"
  }

  part {
    filename     = "99reboot.sh"
    content_type = "text/x-shellscript"
    content      = "#!/usr/bin/env bash\n\ntouch /tmp/completed_user_data ; reboot\n"
  }
}

resource "aws_launch_configuration" "node" {
  depends_on           = ["aws_iam_role_policy.nodes"]
  name_prefix          = "k8s-${var.name}-${var.k8s_version}-node-"
  image_id             = "${var.image_id}"
  user_data            = "${data.template_cloudinit_config.node-init.rendered}"
  instance_type        = "${var.instance_type}"
  spot_price           = "${var.spot_price}"
  key_name             = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes.id}"

  enable_monitoring = false

  security_groups = ["${var.security_group}"]

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

  tags = [
    {
      propagate_at_launch = true
      key                 = "Cluster"
      value               = "k8s-${var.cluster}"
    },
    {
      propagate_at_launch = true
      key                 = "Name"
      value               = "k8s-${var.cluster}-node"
    },
    {
      propagate_at_launch = true
      key                 = "Role"
      value               = "k8s-node"
    },
    {
      propagate_at_launch = true
      key                 = "K8SVersion"
      value               = "${var.k8s_version}"
    },
    {
      propagate_at_launch = true
      key                 = "KubernetesCluster"
      value               = "${var.cluster}"
    },
    {
      propagate_at_launch = true
      key                 = "kubernetes.io/cluster/${var.cluster}"
      value               = "${var.cluster}"
    },
  ]

  tags = ["${var.tags}"]
}
