module "k8s_master" {
  providers = {
    aws = "aws.tokyo"
  }

  source            = "../../modules/k8s_master"
  name              = "${var.cluster}"
  cluster_size      = "${length(var.master_ips)}"
  instance_type     = "c5.large"
  spot_price        = "0.1"
  availability_zone = "${aws_subnet.public_1a.availability_zone}"
  subnet_id         = "${aws_subnet.public_1a.id}"
  image_id          = "${var.ami_id == "" ? data.aws_ami.centos.image_id : var.ami_id}"

  security_groups = [
    "${aws_security_group.k8s_nodes.id}",
  ]

  version                = "${var.version}"
  kube_version           = "${var.kube_version}"
  bootstrap_token        = "${var.bootstrap_token}"
  google_oauth_client_id = "${var.google_oauth_client_id}"

  // Don't create Route53 records if it is empty
  dns_zone_id        = "${var.dns_zone_id}"
  dns_primary_domain = "${var.domain}"

  # bastion          = "${var.bastion}"
  asset_path   = "./assets"
  ssh_key_name = "${aws_key_pair.k8s.key_name}"
  admin_email  = "${var.admin_email}"

  # etcd_endpoints   = "${var.etcd_endpoints}"
  certs_path       = "${path.module}/data/v113"
  master_addresses = "${var.master_ips}"
  datacenter       = "tokyo"

  # Canal
  # pod_network_cidr = "10.244.0.0/16"
  # cni_install_script = <<EOF
  #   kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
  #   kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/canal/canal.yaml
  # EOF

  # Calico
  pod_network_cidr = "192.168.0.0/16"
  cni_install_script = <<EOF
    kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
    kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
  EOF
}
