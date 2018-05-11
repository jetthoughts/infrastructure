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

variable "certs_path" {
  description = "The path to the ZIP file with generated certificates. Example: kubeadm phase certs all"
  default     = ""
}

variable "cert_sans" {
  description = "The list of additinal ips or DNS to access master api server. Splited by comma."
  type        = "string"
  default     = ""
}

variable "kube_version" {
  description = "The version of kubeadm to use"
  default = "v1.11.0-alpha.2"
}
