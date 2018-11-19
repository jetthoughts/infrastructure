module "k8s_node" {
  //  source = "github.com/jetthoughts/infrastructure/modules/k8s_node"
  source            = "../../modules/k8s_node"
  name              = "${var.cluster}"
  instance_type     = "t2.small"
  version           = "${var.version}"
  kube_version      = "${var.kube_version}"
  master_ip         = "internal.v113.japan.pubnative.io"
  bootstrap_token   = "${var.bootstrap_token}"
  availability_zone = "${aws_subnet.public_1a.availability_zone}"
  subnet_id         = "${aws_subnet.public_1a.id}"
  image_id          = "${var.ami_id == "" ? data.aws_ami.centos.image_id : var.ami_id}"

  security_groups = [
    "${aws_security_group.k8s_nodes.id}",
  ]

  ssh_key_name = "${aws_key_pair.k8s.key_name}"
  spot_price   = "0.1"
  min_size     = "1"
  max_size     = "1"

  node_labels = [
    "beta.kubernetes.io/instance-lifecycle=spot",
    "role=general",
  ]

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
      value               = "k8s-node"
      propagate_at_launch = true
    },
  ]
}
