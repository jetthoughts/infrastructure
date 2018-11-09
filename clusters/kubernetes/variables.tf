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
  default = "v20181102"
}

variable "google_oauth_client_id" {}
variable "bootstrap_token" {}

variable "kube_version" {
  default = "v1.13.0-alpha.3"
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
