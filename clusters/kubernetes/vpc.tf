resource "aws_vpc" "kubernetes" {
  provider                         = "aws.tokyo"
  cidr_block                       = "10.0.2.0/23"
  assign_generated_ipv6_cidr_block = true

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name      = "kubernetes"
    Terraform = "true"
  }
}

resource "aws_subnet" "public_1a" {
  provider                = "aws.tokyo"
  vpc_id                  = "${aws_vpc.kubernetes.id}"
  cidr_block              = "10.0.2.0/25"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags {
    Name      = "ap-northeast-1a-public"
    Terraform = "true"
  }

  lifecycle {
    prevent_destroy = true
  }
}
