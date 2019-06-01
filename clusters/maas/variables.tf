# Overide changes in the `terraform.tfvars` or via arguments
# Doc: https://www.terraform.io/intro/getting-started/variables.html

variable "server_ip" {}

variable "server_hostname" {
  default = "maas"
}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

variable "wlan_ssid" {}
variable "wlan_psk" {}

variable "private_ip" {
  default = "10.0.8.1"
}

variable "private_netmask" {
  default = "255.255.255.0"
}

variable "maas_admin" {
  type = "map"

  default = {
    "username" = "admin"
    "email"    = "admin@example.com"
    "password" = "changeme"
  }
}
