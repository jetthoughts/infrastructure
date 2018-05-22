resource "null_resource" "zram" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip_wlan}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "data/zram"
    destination = "/tmp/zram"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/zram | sudo tee /etc/rc.local",
      "sudo bash /tmp/zram",
      "sudo shutdown -r +1",
    ]
  }
}

# https://github.com/madeden/blogposts/blob/master/k8s-gpu-cluster/10-install-maas.md
# Maas Devel: https://docs.ubuntu.com/maas/devel/en/release-notes
# https://docs.maas.io/devel/en/installconfig-package-install
resource "null_resource" "maas-packages" {
  depends_on = ["null_resource.wifi", "null_resource.zram", "null_resource.maas-eth-network"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip_wlan}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo add-apt-repository -yu ppa:maas/next",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "DEBIAN_FRONTEND=noninteractive sudo apt install -yq --no-install-recommends maas bzr isc-dhcp-server wakeonlan amtterm wsmancli zram-config maas-region-controller maas-rack-controller tcpdump",
      "sudo shutdown -r +1",
    ]
  }
}

resource "null_resource" "maas-eth-network" {
  depends_on = ["null_resource.wifi"]
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip_eth}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo touch /etc/sysctl.d/99-maas.conf",
      "echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-maas.conf",
      "sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'",

      "sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE",
      "sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT",
      "sudo sh -c 'iptables-save > /etc/iptables.ipv4.nat'",

      "echo \"allow-hotplug eth0\niface eth0 inet static\n  address ${var.private_ip}\n  netmask ${var.private_netmask}\n up iptables-restore < /etc/iptables.ipv4.nat\" | sudo tee /etc/network/interfaces.d/01-eth0.cfg",
      "sudo rm /etc/network/interfaces.d/50-cloud-init.cfg",
      "sudo ifdown eth0",
      "sudo ifup eth0",
      "sudo shutdown -r +1",
    ]
  }
}

resource "null_resource" "maas-admin" {
  depends_on = ["null_resource.maas-packages"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip_wlan}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo maas createadmin --username=${var.maas_admin["username"]} --email=${var.maas_admin["email"]} --password=${var.maas_admin["password"]}",
    ]
  }
}

output "maas" {
  value = "http://${var.server_ip_wlan}:5240/MAAS"
}
