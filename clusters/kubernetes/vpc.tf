resource "aws_vpc" "kubernetes" {
  count                            = "${var.vpc_id == "" ? 1 : 0}"
  provider                         = "aws.tokyo"
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

resource "aws_security_group" "k8s_nodes" {
  provider    = "aws.tokyo"
  description = "K8s nodes. Managed by Terraform."
  vpc_id      = "${var.vpc_id == "" ? aws_vpc.kubernetes.id : var.vpc_id}"
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

    cidr_blocks = [
      "0.0.0.0/0",
    ]

  }

  // https://kubernetes.io/docs/admin/kubelet/
  // https://kubernetes.io/docs/setup/independent/install-kubeadm/
  ingress {
    from_port = 10250
    to_port   = 10257
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
