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
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA*"]
  }
}

# $ ssh-keygen -f ./assets/k8s_rsa -t rsa -b 4098 -C "k8s"
resource "aws_key_pair" "k8s" {
  provider   = "aws.tokyo"
  key_name   = "k8s_rsa"
  public_key = "${file("./assets/k8s_rsa.pub")}"
}
