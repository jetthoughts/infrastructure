resource "aws_vpc" "kubernetes" {
  count                            = "${var.vpc_id == "" ? 1 : 0}"
  provider                         = "aws.virginia"
  cidr_block                       = "10.0.2.0/23"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name      = "kubernetes"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "main" {
  count  = "${var.vpc_id == "" ? 1 : 0}"
  vpc_id = "${aws_vpc.kubernetes.id}"

  tags {
    Name      = "main"
    Terraform = "true"
  }
}

resource "aws_route_table" "public" {
  count  = "${var.vpc_id == "" ? 1 : 0}"
  vpc_id = "${aws_vpc.kubernetes.id}"

  tags {
    Name      = "public"
    Terraform = "true"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = "${var.vpc_id == "" ? 1 : 0}"
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_subnet" "public_1a" {
  count                   = "${var.vpc_id == "" ? 1 : 0}"
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

resource "aws_route_table_association" "public" {
  count          = "${var.vpc_id == "" ? 1 : 0}"
  subnet_id      = "${aws_subnet.public_1a.id}"
  route_table_id = "${aws_route_table.public.id}"
}
