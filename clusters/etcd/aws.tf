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

resource "aws_key_pair" "etcd_key" {
  provider   = "aws.virginia"
  key_name   = "etcd-key"
  public_key = "${file("${path.module}/assets/etcd-key.pub")}"

  lifecycle {
    ignore_changes = []
  }
}
