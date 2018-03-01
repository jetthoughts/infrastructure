variable "host_connection" {
  type = "map"
  default = {}
}

variable "kube_conf_remote_path" {
  default = "/home/centos/"
}

variable "asset_path" {
  description = "The path to the kubernetes asset path"
  type        = "string"
  default     = "./assets"
}

variable "name" {
  description = "Name of the cluster"
  default = "kubernetes"
}
