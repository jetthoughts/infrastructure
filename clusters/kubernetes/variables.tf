variable "cluster" {
  default = "test"
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
  default = "v20171011"
}

variable "google_oauth_client_id" {}
variable "k8s_token" {}
variable "k8s_version" {
  default = "1.8.0"
}