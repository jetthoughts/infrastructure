variable "cluster" {
  default = "staging"
}

variable "master_addresses" {
  type        = "list"
  description = "Private ip addresses for future masters."
}

variable "cert_sans" {
  type        = "list"
  description = "Private ip addresses for future masters."
  default     = ["localhost"]
}

variable "admin_email" {
  default = "amdin@example.com"
}

variable "version" {
  description = "Mark resources with specific version to find which resources should be upgraded."
  default     = "v20190219"
}

variable "google_oauth_client_id" {}

variable "kubeadm_bootstrap_token" {
  description = "Kubeadm token for adding new nodes. docker run --rm -it miry/kubernetes:v1.14.0-alpha.3  kubeadm token generate"
}

variable "kube_version" {
  default = "v1.14.0-alpha.3"
}

variable "etcd_endpoints" {
  type        = "list"
  description = "The external etcd cluster. E.g.: 'http://10.0.1.1:2379'"
  default     = []
}

variable "ami_id" {
  description = "Existing base image for K8S cluster."
  default     = ""
}

variable "domain" {
  description = "Internal domain name for discovery"
  default     = "k8s.local"
}

variable "dns_zone_id" {
  description = "Route53 zone id"
  default     = ""
}

variable "vpc_id" {
  description = "Create cluster in existing vpc."
  default     = ""
}

variable "availability_zone" {
  description = "Existing availability_zone of your vpc"
  default     = ""
}

variable "subnet_id" {
  description = "Existing subnet id of your vpc"
  default     = ""
}

variable "master_security_groups" {
  description = "Additional security groups for master instances."
  default     = []
}

variable "node_security_groups" {
  description = "Additional security group for node instances."
  default     = []
}
