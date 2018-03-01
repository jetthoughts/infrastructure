terraform {
  required_version = ">= 0.11.2"
}

provider "packet" {
  # env PACKET_AUTH_TOKEN
  auth_token = "${var.packet_auth_token}"
}

resource "packet_project" "k8s_dev" {
  name = "RTB Proxy"
}

resource "packet_ssh_key" "provision" {
  name       = "provision"
  public_key = "${file("${path.module}/assets/k8s.pub")}"
}
