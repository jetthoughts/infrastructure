variable "domain" {
  default = "example.com"
}

variable "vpc_id" {
  description = "To setup cluster, first need to create a VPC"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "subnet_id" {
  description = "For VPC we need to know in which subnet setup a cluster. E.g: subnet-321312312"
  type = "string"
}

variable "key" {
  description = "AWS EC2 key pair name"
  type        = "string"
  default     = "k8s-default"
}

variable "bastion" {
  description = "It is a good practice to use VPN or Bastion instance to connect the private network"
  type    = "map"

  default = {
    host        = "bastion.example.com"
    private_ip  = "10.0.8.1"
    port        = "22"
    user        = "centos"
    private_key = "~/.ssh/id_rsa"
  }
}

variable "asset_path" {
  description = "The path to the kubernetes asset path. Where we keep artifacts from the cluster: certificates"
  type        = "string"
  default     = "./assets"
}

variable "k8s_token" {
  description = "Kubeadm token. Generate a new token: `kubeadm token`"
}

variable "datacenter" {
  description = "Datacenter slug"
  default     = "virginia"
}

variable "version" {
  description = "Keep versions of the Terraform resources. Overide via: export TF_VAR_version=`date +v%Y%m%d` "
  default     = "v20170521"
}

variable "kube_conf_remote_path" {
  description = "To download kubernetes config we need setup some folder that could be access by default user. Depends on Linux distributive, it could be ec2-user, centos or ubuntu"
  default = "/home/centos/admin.conf"
}

variable "google_oauth_client_id" {}
