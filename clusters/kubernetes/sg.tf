resource "aws_security_group" "k8s_base" {
  provider    = "aws.virginia"
  description = "Managed by Terraform."
  vpc_id      = "${local.vpc_id}"
  name        = "k8s-${var.cluster}-base"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    self      = false

    cidr_blocks = [
      "0.0.0.0/0",
    ]

    description = "ssh: Access to the node. Managed by Terraform."
  }

  ingress {
    from_port = 179
    to_port   = 179
    protocol  = "tcp"
    self      = true

    description = "calico: Calico networking (BGP). Managed by Terraform."
  }

  ingress {
    from_port = 5473
    to_port   = 5473
    protocol  = "tcp"
    self      = true

    description = "calico: Calico networking with Typha enabled. Managed by Terraform."
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = false

    cidr_blocks = [
      "0.0.0.0/0",
    ]

    description = "Managed by Terraform."
  }

  tags {
    Name      = "k8s-${var.cluster}-base"
    Cluster   = "${var.cluster}"
    Version   = "${var.version}"
    Terraform = "true"
  }
}

resource "aws_security_group" "k8s_master" {
  provider    = "aws.virginia"
  description = "Managed by Terraform."
  vpc_id      = "${local.vpc_id}"
  name        = "k8s-${var.cluster}-master"

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    self      = true

    cidr_blocks = [
      "0.0.0.0/0",
    ]

    description = "kube-api-server: Send requests to api server from kubectl. Managed by Terraform."
  }

  ingress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    self      = true

    description = "etcd: Configure etcd cluster. Managed by Terraform."
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = false

    cidr_blocks = [
      "0.0.0.0/0",
    ]

    description = "Managed by Terraform."
  }

  tags {
    Name      = "k8s-${var.cluster}-master"
    Cluster   = "${var.cluster}"
    Version   = "${var.version}"
    Terraform = "true"
  }
}

resource "aws_security_group" "k8s_nodes" {
  provider    = "aws.virginia"
  description = "K8s nodes. Managed by Terraform."
  vpc_id      = "${local.vpc_id}"
  name        = "k8s-${var.cluster}-node"

  # // https://kubernetes.io/docs/admin/kubelet/
  # // https://kubernetes.io/docs/setup/independent/install-kubeadm/
  # ingress {
  #   from_port = 10250
  #   to_port   = 10257
  #   protocol  = "tcp"
  #   self      = true
  # }


  # //  cadvisor port
  # ingress {
  #   from_port = 4194
  #   to_port   = 4194
  #   protocol  = "tcp"
  #   self      = true
  # }


  # //  canal-etcd
  # ingress {
  #   from_port = 6666
  #   to_port   = 6666
  #   protocol  = "tcp"
  #   self      = true
  # }


  # //  flannel
  # ingress {
  #   from_port = 8472
  #   to_port   = 8472
  #   protocol  = "udp"
  #   self      = true
  # }

  tags {
    Name      = "k8s-${var.cluster}-node"
    Cluster   = "${var.cluster}"
    Version   = "${var.version}"
    Terraform = "true"
  }
}
