terraform {
  required_version = ">= 0.11.10"
}

provider "aws" {
  version = ">= 1.42"
  region  = "ap-northeast-1"
}

provider "aws" {
  alias   = "tokyo"
  version = ">= 1.42"
  region  = "ap-northeast-1"
}

data "aws_ami" "centos" {
  provider    = "aws.tokyo"
  most_recent = true
  owners      = ["410186602215"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS 1704*"]
  }
}

# $ ssh-keygen -f ./data/k8s_rsa -t rsa -b 4098 -C "k8s"
resource "aws_key_pair" "k8s" {
  provider   = "aws.tokyo"
  key_name   = "k8s_rsa"
  public_key = "${file("./data/k8s_rsa.pub")}"
}

resource "aws_security_group" "k8s_nodes" {
  provider    = "aws.tokyo"
  description = "K8s nodes. Managed by Terraform."
  vpc_id      = "${aws_vpc.kubernetes.id}"         # "${var.vpc_id}"
  name        = "k8s_node_${var.cluster}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    self      = false

    cidr_blocks = [
      "0.0.0.0/0",
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
  // https://kubernetes.io/docs/setup/independent/install-kubeadm/
  ingress {
    from_port = 10250
    to_port   = 10255
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
      "0.0.0.0/0",
    ]
  }

  tags {
    Name      = "k8s-node-${var.cluster}"
    Cluster   = "k8s"
    Version   = "${var.version}"
    Terraform = "true"
  }
}
