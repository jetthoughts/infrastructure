module "k8s_master" {
  providers = {
    aws = "aws"
  }

  source            = "../../modules/k8s_master"
  name              = "${var.cluster}"
  instance_type     = "c5.large"
  spot_price        = "0.1"
  availability_zone = "${local.availability_zone}"
  subnet_id         = "${local.subnet_id}"
  image_id          = "${local.ami_id}"

  security_groups = "${local.master_security_groups}"

  version                = "${var.version}"
  kube_version           = "${var.kube_version}"
  bootstrap_token        = "${var.kubeadm_bootstrap_token}"
  google_oauth_client_id = "${var.google_oauth_client_id}"

  // Don't create Route53 records if it is empty
  dns_zone_id        = "${var.dns_zone_id}"
  dns_primary_domain = "${var.domain}"

  # bastion          = "${var.bastion}"
  asset_path   = "./assets"
  ssh_key_name = "${aws_key_pair.k8s.key_name}"
  admin_email  = "${var.admin_email}"

  etcd_endpoints   = "${var.etcd_endpoints}"
  etcd_prefix      = "/${var.cluster}"
  certs_path       = "${path.module}/assets/${var.cluster}"
  master_addresses = "${var.master_addresses}"
  cert_sans        = "${var.cert_sans}"

  # Calico
  pod_network_cidr     = "192.168.0.0/16"
  service_network_cidr = "10.96.0.0/12"

  cni_install_script = <<EOF
kubectl apply -f https://docs.projectcalico.org/v3.5/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

kubectl -n kube-system get po,no -o wide
  EOF

  tags = {
    Role      = "kube_master"
    Terraform = "true"
    Cluster   = "${var.cluster}"
    Version   = "${var.version}"
  }
}
