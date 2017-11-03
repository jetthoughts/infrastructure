variable "version" {
  default = "v20171102"
}

# curl -w "\n" 'https://discovery.etcd.io/new?size=3'
variable "discovery" {}

variable "cluster" {
  default = "test"
}

variable "cluster_size" {
  default = "3"
}

variable "public_key" {}

// Required AWS resources
variable "vpc_id" {}

variable "subnet_id" {}
variable "security_group" {}

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
