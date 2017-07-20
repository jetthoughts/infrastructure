data "template_file" "master_user_data" {
  template = "${file("${path.module}/data/master_init.tpl.sh")}"

  vars {
    k8s_token              = "${var.k8s_token}"
    k8s_version            = "${var.k8s_version}"
    k8s_pod_network_cidr   = "${var.k8s_pod_network_cidr}"
    domain                 = "api.${var.name}.${var.datacenter}.${var.dns_primary_domain}"
    google_oauth_client_id = "${var.google_oauth_client_id}"
  }
}

data "template_cloudinit_config" "master-init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "01master.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.master_user_data.rendered}"
  }

  part {
    filename     = "02k8s_admins.sh"
    content_type = "text/x-shellscript"
    content      = "#!/usr/bin/env bash\n\nkubectl --kubeconfig=/etc/kubernetes/admin.conf create clusterrolebinding cluster-admin-mn --clusterrole=cluster-admin --user=${var.admin_email}\n"
  }

  part {
    filename     = "99reboot.sh"
    content_type = "text/x-shellscript"
    content      = "#!/usr/bin/env bash\n\ntouch /tmp/completed_user_data ; reboot\n"
  }
}

resource "aws_launch_configuration" "master" {
  name_prefix       = "k8s-${var.name}-${var.version}-master-"
  image_id          = "${var.image_id}"
  user_data         = "${data.template_cloudinit_config.master-init.rendered}"
  instance_type     = "c4.large"
  key_name          = "${var.ssh_key_name}"
  enable_monitoring = false
  spot_price        = "${var.spot_price}"
  security_groups   = ["${var.security_group}"]

  root_block_device = {
    volume_type           = "standard"
    volume_size           = 20
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "master" {
  name                 = "k8s-${var.name}-${var.version}-master"
  launch_configuration = "${aws_launch_configuration.master.name}"

  availability_zones = [
    "${var.availability_zone}",
  ]

  vpc_zone_identifier = [
    "${var.subnet_id}",
  ]

  min_size         = "1"
  max_size         = "1"

  termination_policies = [
    "OldestInstance",
  ]

  lifecycle {
    prevent_destroy = true
  }

  tag {
    propagate_at_launch = true
    key                 = "Cluster"
    value               = "k8s"
  }

  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "k8s-${var.name}-master"
  }

  tag {
    propagate_at_launch = true
    key                 = "Role"
    value               = "k8s-master"
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
}
