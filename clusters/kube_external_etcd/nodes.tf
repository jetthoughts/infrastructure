module "k8s_node" {
  providers = {
    aws = "aws"
  }

  source = "../../modules/k8s_node"
  name   = "${var.cluster}"

  instance_type     = "t3.nano"
  spot_price        = "0.005"
  min_size          = "2"
  max_size          = "2"
  availability_zone = "${local.availability_zone}"
  subnet_id         = "${local.subnet_id}"
  image_id          = "${local.ami_id}"
  security_groups   = "${local.node_security_groups}"
  ssh_key_name      = "${aws_key_pair.k8s.key_name}"
  kube_version      = "${var.kube_version}"
  bootstrap_token   = "${var.kubeadm_bootstrap_token}"
  master_ip         = "${module.k8s_master.internal_domain[0]}"

  # node_labels = [
  #   "beta.kubernetes.io/instance-lifecycle=spot",
  #   "role=general",
  # ]

  tags = [
    {
      key                 = "kubernetes.io/cluster/${var.cluster}"
      value               = "true"
      propagate_at_launch = false
    },
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "k8s_node_${var.cluster}"
      propagate_at_launch = true
    },
    {
      key                 = "Role"
      value               = "kube_node"
      propagate_at_launch = true
    },
    {
      key                 = "KubernetesCluster"
      value               = "${var.cluster}"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${var.cluster}"
      propagate_at_launch = true
    },
    {
      key                 = "Version"
      value               = "${var.version}"
      propagate_at_launch = true
    },
  ]
}
