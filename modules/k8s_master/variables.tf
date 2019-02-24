variable "name" {
  default = "staging"
}

variable "asset_path" {
  description = "The path to the kubernetes asset path"
  type        = "string"
  default     = "./assets"
}

variable "bootstrap_token" {
  description = "Kubeadm token. Generate a new token: `kubeadm token`"
}

variable "kube_version" {
  default = "v1.14.0-alpha.2"
}

variable "pod_network_cidr" {
  default = "192.168.0.0/16"
}

variable "service_network_cidr" {
  default = "10.96.0.0/12"
}

variable "k8s_ca_crt" {
  default = ""
}

variable "instance_type" {
  default = "c5.large"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "subnet_id" {}

variable "remote_user" {
  default = "centos"
}

variable "kube_conf_remote_path" {
  default = "/home/centos/"
}

variable "image_id" {}
variable "ssh_key_name" {}

variable "security_groups" {
  type = "list"
}

variable "google_oauth_client_id" {}

variable "dns_zone_id" {
  description = "Route53 ZoneID"
  default     = ""
}

variable "dns_primary_domain" {
  default = "example.com"
}

variable "dns_ttl" {
  default = "300"
}

variable "bastion" {
  description = "Access to the cluster via SSH bastion instance"
  type        = "map"

  default = {
    host        = ""
    port        = 0
    user        = "centos"
    private_key = ""
  }
}

variable "admin_email" {
  description = "Admin email"
}

variable "etcd_endpoints" {
  type        = "list"
  description = "The external etcd cluster."
  default     = []
}

variable "etcd_prefix" {
  type        = "string"
  description = "ETCD namespace for the clsuter. Default: /registry"
  default     = "/registry"
}

variable "certs_path" {
  description = "The path to the ZIP file with generated certificates. Example: kubeadm phase certs all"
  default     = "./data/pki"
}

variable "master_addresses" {
  description = "The list of predefined Private IP addresses for masters. (To generate certificates we need to know ips.)"
  type        = "list"
  default     = []
}

variable "cert_sans" {
  description = "The list of additinal ips or names to access master api server"
  type        = "list"
  default     = []
}

variable "tags" {
  type        = "map"
  description = "AWS instance and volume tags"

  default = {
    Terraform = "true"
  }
}

variable "kubelet_extra_args" {
  type        = "list"
  description = "List of kubelet args"

  default = [
    "--cloud-provider=aws",
  ]
}

variable "pre_init_script" {
  description = "Content to be run before the kubeadm."
  default = <<EOF
    echo "Pre init script:"
  EOF
}

variable "post_init_script" {
  default = <<EOF
kubectl apply -f https://docs.projectcalico.org/v3.5/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
  EOF
}

variable "source_dest_check" {
  default = true
}

variable "disable_api_termination" {
  default = true
}

variable "ebs_optimized" {
  default = true
}

variable "monitoring" {
  default = false
}

variable "root_volume_size" {
  default = "8"
}

variable "root_volume_type" {
  default = "standard"
}
