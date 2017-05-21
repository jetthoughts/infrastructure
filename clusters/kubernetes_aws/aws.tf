provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

data "aws_ami" "centos_virginia" {
  provider    = "aws.virginia"
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["centos-7-*"]
  }
}

resource "aws_key_pair" "zero-pn-k8s-key" {
  key_name   = "${var.key}"
  public_key = "public_key_content"
}
