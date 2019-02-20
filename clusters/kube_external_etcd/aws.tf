terraform {
  required_version = ">= 0.11.11"
}

provider "aws" {
  version = ">= 1.59"
  region  = "ap-northeast-1"
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA*"]
  }
}

# $ ssh-keygen -f ./assets/k8s_rsa -t rsa -b 4098 -C "k8s"
# $ cp ./assets/k8s_rsa.pub ./data/
resource "aws_key_pair" "k8s" {
  key_name   = "k8s_rsa"
  public_key = "${file("./data/k8s_rsa.pub")}"
}

locals {
  ami_id            = "${var.ami_id == "" ? data.aws_ami.centos.image_id : var.ami_id}"
  availability_zone = "${var.availability_zone == "" ? element(concat(aws_subnet.public_1a.*.availability_zone, list("")), 0) : var.availability_zone}"
  subnet_id         = "${var.subnet_id == "" ? element(concat(aws_subnet.public_1a.*.id, list("")), 0) : var.subnet_id}"

  vpc_id = "${var.vpc_id == "" ? element(concat(aws_vpc.kubernetes.*.id, list("")), 0) : var.vpc_id}"

  master_security_groups = "${compact( concat ( list(aws_security_group.k8s_base.id, aws_security_group.k8s_master.id), var.master_security_groups ) ) }"
  node_security_groups   = "${compact( concat ( list(aws_security_group.k8s_base.id, aws_security_group.k8s_node.id), var.node_security_groups ) ) }"
}
