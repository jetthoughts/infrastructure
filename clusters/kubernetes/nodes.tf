module "k8s_node" {
  //  source = "github.com/jetthoughts/infrastructure/modules/k8s_node"
  source            = "../../modules/k8s_node"
  name              = "${var.cluster}"
  cluster           = "${var.cluster}"
  instance_type     = "r4.large"
  version           = "${var.version}"
  k8s_version       = "${var.k8s_version}"
  master_ip         = "api.test.virginia.pubnative.io"
  k8s_token         = "${var.k8s_token}"
  availability_zone = "us-east-1a"
  subnet_id         = "${var.subnet_id}"
  image_id          = "${var.ami_id == "" ? data.aws_ami.centos.image_id : var.ami_id}"
  security_group    = "${aws_security_group.k8s_nodes.id}"
  ssh_key_name      = "${aws_key_pair.k8s_key.key_name}"
  spot_price        = "0.1"
  min_size          = "2"
  max_size          = "2"

  node_labels = [
    "beta.kubernetes.io/instance-lifecycle=spot",
    "role=general",
  ]

  tags = [
    {
      key                 = "k8s.io/cluster-autoscaler/enabled"
      value               = "true"
      propagate_at_launch = false
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster}"
      value               = "true"
      propagate_at_launch = false
    },
  ]
}
