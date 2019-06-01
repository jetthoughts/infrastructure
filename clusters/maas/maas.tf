# https://github.com/madeden/blogposts/blob/master/k8s-gpu-cluster/10-install-maas.md
# Maas Devel: https://docs.ubuntu.com/maas/devel/en/release-notes
# https://docs.maas.io/devel/en/installconfig-package-install
resource "null_resource" "maas-packages" {
  depends_on = ["null_resource.wifi", "null_resource.zram", "null_resource.maas-eth-network"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = "${var.server_ip}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      # 04E7FDC5684D4A1C - public key "Launchpad PPA for MAAS"
      "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04E7FDC5684D4A1C",
      "sudo apt-get -y update",
      "sudo apt-add-repository -yu ppa:maas/next",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "DEBIAN_FRONTEND=noninteractive sudo apt install -yq --no-install-recommends maas bzr isc-dhcp-server wakeonlan amtterm wsmancli zram-config maas-region-controller maas-rack-controller tcpdump",
      "sudo shutdown -r +1",
    ]
  }
}

resource "null_resource" "maas-eth-network" {
  depends_on = ["null_resource.networking"]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = "${var.server_ip}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-maas.conf",
      "echo 'net.core.netdev_budget=3000' | sudo tee -a /etc/sysctl.d/99-maas.conf",
      "echo 'net.core.netdev_budget_usecs=20000' | sudo tee -a /etc/sysctl.d/99-maas.conf",
      "sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent netfilter-persistent",
      "sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE",
      "sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT",

      "sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE",
      "sudo iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT",

      "sudo netfilter-persistent save",

      "echo \"network:\\n  version: 2\\n  ethernets:\\n    eth0:\\n      dhcp4: no\\n      addresses:\\n        - ${var.private_ip}/24\\n\" | sudo tee /etc/netplan/40-static.yaml",
      "sudo rm /etc/netplan/50-cloud-init.yaml",
      "sudo netplan --debug apply",
      "sudo shutdown -r +1",
    ]
  }
}

resource "null_resource" "maas-admin" {
  depends_on = ["null_resource.maas-packages"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = "${var.server_ip}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo maas createadmin --username=${var.maas_admin["username"]} --email=${var.maas_admin["email"]} --password=${var.maas_admin["password"]}",
    ]
  }
}

output "maas" {
  value = "http://${var.server_ip}:5240/MAAS"
}
