resource "aws_autoscaling_group" "k8s-master-v20170521" {
  name                 = "k8s-master-${var.version}"
  launch_configuration = "${aws_launch_configuration.k8s-master-v20170521.name}"

  availability_zones = [
    "${var.availability_zone}",
  ]

  vpc_zone_identifier = [
    "${var.subnet_id}",
  ]

  min_size         = "0"
  max_size         = "1"
  desired_capacity = "1"

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
    value               = "k8s-master-spotinst"
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
}

resource "aws_launch_configuration" "k8s-master-v20170521" {
  name_prefix       = "k8s-master-${var.version}-"
  image_id          = "${data.aws_ami.centos_virginia.id}"
  user_data         = "${data.template_cloudinit_config.k8s-master-init.rendered}"
  instance_type     = "c4.large"
  spot_price        = "0.1"
  key_name          = "${aws_key_pair.zero-pn-k8s-key.key_name}"
  enable_monitoring = false

  security_groups = [
    "${aws_security_group.k8s_nodes.id}",
  ]

  root_block_device = {
    volume_type           = "standard"
    volume_size           = 20
    delete_on_termination = true
  }
}

data "template_cloudinit_config" "k8s-master-init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "01install_packages.sh"
    content_type = "text/x-shellscript"
    content      = "${file("data/install_packages.sh")}"
  }

  part {
    filename     = "01master.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.master_user_data.rendered}"
  }

  part {
    filename     = "02k8s_admins.sh"
    content_type = "text/x-shellscript"
    content      = "#!/usr/bin/env bash\n\nkubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://gist.githubusercontent.com/miry/badcdeaa3cdfbd5f642a4e3a5f1c7bae/raw/09a4a029b930b639c9326ce746e6ef1b0927a015/admins.yaml --validate=false\n"
  }

  part {
    filename     = "99reboot.sh"
    content_type = "text/x-shellscript"
    content      = "#!/usr/bin/env bash\n\ntouch /tmp/completed_user_data ; reboot\n"
  }
}

data "template_file" "master_user_data" {
  template = "${file("${path.module}/data/master_init.sh.tpl")}"

  vars {
    k8s_token              = "${var.k8s_token}"
    domain                 = "${var.datacenter}.${aws_route53_zone.kb.name}"
    google_oauth_client_id = "${var.google_oauth_client_id}"
  }
}

data "aws_instance" "master" {
  instance_tags {
    "aws:autoscaling:groupName" = "${aws_autoscaling_group.k8s-master-v20170521.name}"
  }

  filter {
    name = "instance-state-name"

    values = [
      "running",
    ]
  }
}

resource "null_resource" "download-ca-certificate" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    master_public_ip = "${data.aws_instance.master.public_ip}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host                = "${data.aws_instance.master.private_ip}"
    user                = "centos"
    private_key         = "${file("~/.ssh/${aws_key_pair.zero-pn-k8s-key.key_name}")}"
    bastion_host        = "${var.bastion["host"]}"
    bastion_user        = "${var.bastion["user"]}"
    bastion_port        = "${var.bastion["port"]}"
    bastion_private_key = "${file(var.bastion["private_key"])}"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "ls -la /home/centos",
      "while [ ! -f ${var.kube_conf_remote_path} ] ; do tail /var/log/cloud-init-output.log; sleep 30; date; done",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -o ProxyCommand="ssh -q -W %h:%p ${var.bastion["user"]}@${var.bastion["host"]} -p ${var.bastion["port"]} -i ${var.bastion["private_key"]}" ${data.aws_instance.master.private_ip}:${var.kube_conf_remote_path} ${var.asset_path}
      ruby extract_crt.rb -s assets/admin.conf -d assets
      kubectl config set-cluster virginia --server="https://${data.aws_instance.master.private_ip}:6443" --certificate-authority=${var.asset_path}/ca.crt
CMD
  }
}
