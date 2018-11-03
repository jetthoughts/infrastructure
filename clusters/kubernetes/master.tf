module "k8s_master" {
  providers = {
    aws = "aws.tokyo"
  }
  source            = "../../modules/k8s_master"
  name              = "${var.cluster}"
  cluster_size      = "${var.masters_count}"
  instance_type     = "c5.large"
  spot_price        = "0.1"
  availability_zone = "${aws_subnet.public_1a.availability_zone}"
  subnet_id         = "${aws_subnet.public_1a.id}"
  image_id          = "${var.ami_id == "" ? data.aws_ami.centos.image_id : var.ami_id}"

  security_groups = [
    "${aws_security_group.k8s_nodes.id}",
  ]

  version                = "${var.version}"
  kube_version           = "${var.k8s_version}"
  k8s_token              = "${var.k8s_token}"
  google_oauth_client_id = "${var.google_oauth_client_id}"

  // Don't create Route53 records if it is empty
  dns_zone_id        = "${var.dns_zone_id}"
  dns_primary_domain = "${var.domain}"

  # bastion          = "${var.bastion}"
  asset_path       = "./assets"
  ssh_key_name     = "${aws_key_pair.k8s.key_name}"
  admin_email      = "${var.admin_email}"
  # etcd_endpoints   = "${var.etcd_endpoints}"
  certs_path       = "${path.module}/data/v113"
  master_addresses = "${var.master_ips}"
  datacenter = "tokyo"
}
