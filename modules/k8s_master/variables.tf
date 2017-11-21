variable "name" {
  default = "staging"
}

variable "cluster_size" {
  default = "1"
}

variable "asset_path" {
  description = "The path to the kubernetes asset path"
  type        = "string"
  default     = "./assets"
}

variable "k8s_token" {
  description = "Kubeadm token. Generate a new token: `kubeadm token`"
}

variable "k8s_version" {
  default = "v1.8.4"
}

variable "k8s_pod_network_cidr" {
  default = "10.244.0.0/16"
}

variable "k8s_ca_crt" {
  default = ""
}

variable "datacenter" {
  description = "Datacenter name"
  default     = "virginia"
}

variable "instance_type" {
  default = "r4.large"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "subnet_id" {}

variable "version" {
  default = "v20171122"
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

variable "bastion" {
  description = "Access to the cluster via SSH bastion instance"
  type        = "map"

  default = {
    host        = ""
    port        = ""
    user        = ""
    private_key = ""
  }
}

variable "admin_email" {
  description = "Admin email"
}

variable "spot_price" {
  description = "If empty used Demand instances"
  default     = ""
}

variable "etcd_endpoints" {
  type        = "list"
  description = "The external etcd cluster."
  default     = []
}

variable "certs_path" {
  description = "The path to the ZIP file with generated certificates. Example: kubeadm phase certs all"
  default     = ""
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
