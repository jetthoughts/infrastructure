# Overide changes in the `terraform.tfvars` or via arguments
# Doc: https://www.terraform.io/intro/getting-started/variables.html

variable "server_ip" {}
variable "server_ip_eth" {}
variable "server_ip_wlan" {}
variable "server_hostname" {}
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
