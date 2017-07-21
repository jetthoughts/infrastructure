variable "name" {
  default = "staging"
}

variable "version" {
  default = "v20170715"
}

variable "k8s_version" {
  default = "v1.7.1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "subnet_id" {}

variable "master_ip" {
  description = "The private ip of kubernetes master"
}

variable "image_id" {}

variable "ssh_key_name" {}

variable "security_group" {}

variable "k8s_token" {
  description = "Kubeadm token. Generate a new token: `kubeadm token`"
}

variable "spot_price" {
  description = "If empty used Demand instances"
  default     = "0.1"
}
