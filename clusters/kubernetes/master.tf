module "k8s_master" {
  source                 = "../../modules/k8s_master"
  name                   = "${var.cluster}"
  instance_type          = "c4.large"
  spot_price             = "0.1"
  availability_zone      = "us-east-1a"
  subnet_id              = "${var.subnet_id}"
  image_id               = "${data.aws_ami.centos.image_id}"
  security_group         = "${aws_security_group.k8s_nodes.id}"
  
  version                = "${var.version}"
  k8s_version            = "${var.k8s_version}"
  k8s_token              = "${var.k8s_token}"
  google_oauth_client_id = "${var.google_oauth_client_id}"

  // Don't create Route53 records
  dns_zone_id            = ""
  dns_primary_domain     = "example.com"
  
  bastion                = "${var.bastion}"
  asset_path             = "./assets"
  ssh_key_name           = "${aws_key_pair.k8s_key.key_name}"
  admin_email            = "${var.admin_email}"
}
