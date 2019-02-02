variable "cluster" {
  default = "staging"
}

variable "master_ips" {
  type        = "list"
  description = "Private ip addresses for future masters."
}

variable "admin_email" {
  default = "amdin@example.com"
}

variable "version" {
  default = "v20190202"
}

variable "google_oauth_client_id" {}

variable "kubeadm_bootstrap_token" {
  description = "Kubeadm token for adding new nodes. docker run --rm -it miry/kubernetes:v1.14.0-alpha.2  kubeadm token generate"
}

variable "kube_version" {
  default = "v1.14.0-alpha.2"
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
  default = ""
}

variable "subnet_id" {
  description = "Existing subnet id of your vpc"
  default = ""
}
