# Generate https://app.packet.net/users/<user id>/api-keys
variable "packet_auth_token" {}

variable "cluster_size" {
  default = 1
}

variable "certs_path" {
  description = "The path to the ZIP file with generated certificates. Example: kubeadm phase certs all"
  default     = "data/pki"
}

variable "master_addresses" {
  description = "The list of predefined Private IP addresses for masters. (To generate certificates we need to know ips.)"
  type        = "list"
  default     = []
}

variable "node_ips" {
  type = "list"
}

variable "etcd_endpoints" {
  type        = "list"
  description = "The external etcd cluster."
  default     = []
}

variable "k8s_token" {
  description = "Kubeadm token. Generate a new token: `kubeadm token generate`"
}

variable "k8s_discovery_hash" {
  description = "Kubeadm discovery token"
  default     = ""
}

variable "k8s_version" {
  default = ""
}

variable "k8s_pod_network_cidr" {
  default = "10.244.0.0/16"
}

variable "k8s_ca_crt" {
  default = ""
}

variable "domain" {
  default = "ny.exmaple.com"
}

variable "google_oauth_client_id" {
  default = ""
}

variable "cert_sans" {
  description = "The list of additinal ips or names to access master api server"
  type        = "list"
  default     = []
}

variable "admin_email" {
  description = "Admin email"
}

variable "asset_path" {
  default = "./assets"
}

variable "kube_conf_remote_path" {
  default = "/root/"
}

// Nodes
variable "node_labels" {
  type = "list"
  default = []
}

variable "pre_init_script" {
  description = "Content to be run before the kubeadm."
  default = ""
}
