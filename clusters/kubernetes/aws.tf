provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_ami" "centos" {
  provider    = "aws.virginia"
  most_recent = true
  owners      = ["410186602215"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS 1704*"]
  }
}

resource "aws_key_pair" "k8s_key" {
  provider   = "aws.virginia"
  key_name   = "k8s-key"
  public_key = "${var.public_key}"

  lifecycle {
    ignore_changes = []
  }
}

resource "aws_security_group" "k8s_nodes" {
  provider    = "aws.virginia"
  description = "K8s nodes"
  vpc_id      = "${var.vpc_id}"
  name        = "k8s-node-${var.cluster}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    self      = false

    cidr_blocks = [
      "${var.bastion["private_ip"]}/32",
    ]
  }

  //  kube-apiserve
  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    self      = true
  }

  // https://kubernetes.io/docs/admin/kubelet/
  //  kubelet-ready-port
  ingress {
    from_port = 10255
    to_port   = 10255
    protocol  = "tcp"
    self      = true
  }

  //  kubelet-serve-port
  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    self      = true
  }

  //  cadvisor port
  ingress {
    from_port = 4194
    to_port   = 4194
    protocol  = "tcp"
    self      = true
  }

  //  canal-etcd
  ingress {
    from_port = 6666
    to_port   = 6666
    protocol  = "tcp"
    self      = true
  }

  //  flannel
  ingress {
    from_port = 8472
    to_port   = 8472
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = false

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags {
    Name      = "k8s-node-${var.cluster}"
    Cluster   = "k8s"
    Version   = "${var.version}"
    Terraform = "true"
  }
}