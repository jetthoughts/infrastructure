resource "aws_autoscaling_group" "k8s-node-v20170521" {
  name                 = "k8s-node-${var.version}"
  availability_zones   = [
    "${var.availability_zone}"
  ]
  vpc_zone_identifier  = [
    "${var.subnet_id}"
  ]

  min_size             = "0"
  max_size             = "3"
  desired_capacity     = "3"
  launch_configuration = "${aws_launch_configuration.k8s-node-v20170521.name}"

  termination_policies = [
    "OldestInstance",
  ]

  tag {
    propagate_at_launch = true
    key                 = "Cluster"
    value               = "k8s"
  }

  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "k8s-node-spotinst"
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
}

resource "aws_launch_configuration" "k8s-node-v20170521" {
  name_prefix       = "k8s-node-${var.version}-"
  image_id          = "${data.aws_ami.centos_virginia.id}"
  user_data         = "${data.template_cloudinit_config.k8s-node-init.rendered}"
  instance_type     = "c4.large"
  spot_price        = "0.1"
  key_name          = "${var.key}"
  enable_monitoring = false

  security_groups   = [
    "${aws_security_group.k8s_nodes.id}",
  ]

  root_block_device = {
    volume_type           = "standard"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_cloudinit_config" "k8s-node-init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "01install_packages.sh"
    content_type = "text/x-shellscript"
    content      = "${file("data/install_packages.sh")}"
  }

  part {
    filename     = "01node.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.node_join.rendered}"
  }
}

data "template_file" "node_join" {
  template = "${file("${path.module}/data/node_join.sh.tpl")}"

  vars {
    k8s_token = "${var.k8s_token}"
    master_ip = "${data.aws_instance.master.private_ip}"
  }
}

