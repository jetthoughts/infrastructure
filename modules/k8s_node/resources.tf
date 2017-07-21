data "template_file" "node_join" {
  template = "${file("${path.module}/data/node_join.tpl.sh")}"

  vars {
    k8s_token   = "${var.k8s_token}"
    k8s_version = "${var.k8s_version}"
    master_ip   = "${var.master_ip}"
  }
}

data "template_cloudinit_config" "node-init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "01node.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.node_join.rendered}"
  }
}

resource "aws_launch_configuration" "node" {
  name_prefix       = "k8s-${var.name}-${var.version}-node-"
  image_id          = "${var.image_id}"
  user_data         = "${data.template_cloudinit_config.node-init.rendered}"
  instance_type     = "c4.large"
  spot_price        = "${var.spot_price}"
  key_name          = "${var.ssh_key_name}"
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
  name                 = "k8s-${var.name}-${var.version}-node"
  availability_zones = [
    "${var.availability_zone}",
  ]

  vpc_zone_identifier = [
    "${var.subnet_id}",
  ]
  min_size             = "1"
  max_size             = "3"
  launch_configuration = "${aws_launch_configuration.node.name}"

  tag {
    propagate_at_launch = true
    key                 = "Cluster"
    value               = "k8s"
  }

  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "k8s-${var.name}-node"
  }

  tag {
    propagate_at_launch = true
    key                 = "Role"
    value               = "k8s-node"
  }

  tag {
    propagate_at_launch = true
    key                 = "Terraform"
    value               = "true"
  }

  tag {
    propagate_at_launch = true
    key                 = "Version"
    value               = "${var.version}"
  }

  tag {
    propagate_at_launch = true
    key                 = "K8SVersion"
    value               = "${var.k8s_version}"
  }

  tag {
    propagate_at_launch = true
    key                 = "K8SMaster"
    value               = "${var.master_ip}"
  }
}
