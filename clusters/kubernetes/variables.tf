variable "cluster" {
  default = "test"
}

variable "masters_count" {
  default = "1"
}

variable "master_ips" {
  type = "list"

  default = [
    "10.0.1.11",
    "10.0.1.12",
    "10.0.1.13",
  ]
}

variable "admin_email" {
  default = "amdin@example.com"
}

variable "public_key" {}

// Required AWS resources
variable "vpc_id" {}

variable "subnet_id" {}

variable "bastion" {
  type = "map"

  default = {
    host        = "8.8.8.8"
    private_ip  = "10.0.0.1"
    port        = "22"
    user        = "bastion"
    private_key = "~/.ssh/id_rsa"
  }
}

variable "version" {
  default = "v20171113"
}

variable "google_oauth_client_id" {}
variable "k8s_token" {}

variable "k8s_version" {
  default = "v1.11.2"
}

variable "etcd_endpoints" {
  type        = "list"
  description = "The external etcd cluster. E.g.: 'http://10.0.1.1:2379'"
  default     = []
}

variable "ami_id" {
  description = "Existing base image for K8S cluster."
}

variable "domain" {
  description = "Internal domain name for discovery"
  default     = "k8s.local"
}

variable "dns_zone_id" {
  description = "Route53 zone id"
}
