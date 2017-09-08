variable "name" {
  default = "staging"
}

variable "cluster" {
  default = "staging"
}

variable "version" {
  default = "v20170901"
}

variable "k8s_version" {
  default = "v1.7.1"
}

variable "node_labels" {
  type    = "list"
  default = []
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "subnet_id" {}

variable "master_ip" {
  description = "The private ip of kubernetes master"
}

variable "image_id" {}

variable "instance_type" {
  default = "r4.large"
}

variable "ssh_key_name" {}

variable "security_group" {}

variable "k8s_token" {
  description = "Kubeadm token. Generate a new token: `kubeadm token`"
}

variable "spot_price" {
  description = "If empty used Demand instances"
  default     = "0.1"
}

variable "min_size" {
  description = "Minimum number of instances"
  default     = "1"
}

variable "max_size" {
  description = "Minimum number of instances"
  default     = "1"
}

variable "tags" {
  description = "Autoscaling tags"

  default = [
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]
}
