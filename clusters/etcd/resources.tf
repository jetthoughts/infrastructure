data "template_file" "config" {
  template = "${file("${path.module}/data/etcd_config.tpl.sh")}"

  vars = {
    discovery     = "${var.discovery}"
    discovery_srv = ""
    ssl           = "false"
  }
}

data "template_cloudinit_config" "master_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "01packages.sh"
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/data/packages.sh")}"
  }

  part {
    filename     = "10config.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.config.rendered}"
  }

  part {
    filename     = "99reboot.sh"
    content_type = "text/x-shellscript"
    content      = "#!/usr/bin/env bash\n\ntouch /tmp/completed_user_data ; reboot\n"
  }
}

resource "aws_security_group" "master" {
  provider    = "aws.virginia"
  description = "ETCD server"
  vpc_id      = "${var.vpc_id}"
  name        = "etcd-cluster-master-${var.cluster}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    self      = false

    cidr_blocks = [
      "${var.bastion["private_ip"]}/32",
    ]
  }

  ingress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 4001
    to_port   = 4001
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = false

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name      = "etcd-cluster-master-${var.cluster}"
    Cluster   = "${var.cluster}"
    Version   = "${var.version}"
    Terraform = "true"
  }
}

resource "aws_spot_instance_request" "master" {
  count                = "${var.cluster_size}"
  ami                  = "${data.aws_ami.centos.id}"
  instance_type        = "c4.large"
  spot_price           = "0.1"
  availability_zone    = "us-east-1a"
  subnet_id            = "${var.subnet_id}"
  security_groups      = ["${var.security_group}", "${aws_security_group.master.id}"]
  key_name             = "${aws_key_pair.etcd_key.key_name}"
  user_data_base64     = "${data.template_cloudinit_config.master_init.rendered}"
  wait_for_fulfillment = true

  tags {
    Name      = "etcd-cluster-master-${var.cluster}-${count.index}"
    Role      = "discovery"
    Version   = "${var.version}"
    Cluster   = "${var.cluster}"
    Terraform = "true"
  }
}

output "ips" {
  value = "${join(" ", aws_spot_instance_request.master.*.private_ip)}"
}
