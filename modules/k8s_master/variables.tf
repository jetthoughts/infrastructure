variable "name" {
  default = "staging"
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
  default = "v1.7.1"
}

variable "datacenter" {
  description = "Datacenter name"
  default     = "virginia"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "subnet_id" {}

variable "version" {
  default = "v20170715"
}

variable "kube_conf_remote_path" {
  default = "/home/centos/admin.conf"
}

variable "image_id" {}
variable "ssh_key_name" {}
variable "security_group" {}
variable "google_oauth_client_id" {}
variable "dns_zone_id" {
  description = "Route53 ZoneID"
}
variable "dns_primary_domain" {
  default = "example.com"
}
variable "bastion" {
  description = "Access to the cluster via SSH bastion instance"
  type        = "map"
  default     = {
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
  default = ""
}