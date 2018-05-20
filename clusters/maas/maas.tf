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
resource "null_resource" "maas-packages" {
  depends_on = ["null_resource.wifi", "null_resource.zram"]

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
      "DEBIAN_FRONTEND=noninteractive sudo apt install -yq --no-install-recommends maas bzr isc-dhcp-server wakeonlan amtterm wsmancli zram-config maas-region-controller",
      "sudo shutdown -r +1",
    ]
  }
}

resource "null_resource" "maas-eth-network" {
  depends_on = ["null_resource.maas-packages"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip_eth}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"allow-hotplug eth0\niface eth0 inet static\n  address ${var.private_ip}\n  netmask ${var.private_netmask}\" | sudo tee /etc/network/interfaces.d/01-eth0.cfg",
      "sudo rm /etc/network/interfaces.d/50-cloud-init.cfg",
      "sudo ifdown eth0",
      "sudo ifup eth0",
      // "sudo dpkg-reconfigure maas-region-controller",
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
