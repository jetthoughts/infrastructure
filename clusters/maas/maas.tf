resource "null_resource" "zram" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "file" {
    source      = "data/zram"
    destination = "/tmp/zram"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/zram | sudo tee /etc/rc.local",
      "sudo bash /tmp/zram",
      "sudo reboot"
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
    host = "${var.server_ip}"
  }

  provisioner "file" {
    source      = "data/rc.local"
    destination = "/tmp/rc.local"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-add-repository -yu ppa:maas/next",
      "DEBIAN_FRONTEND=noninteractive sudo apt install -yqq --no-install-recommends maas bzr isc-dhcp-server wakeonlan amtterm wsmancli zram-config maas-region-controller",
      "sudo reboot"
    ]
  }
}

resource "null_resource" "maas-eth-network" {
  depends_on = ["null_resource.maas-packages"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"allow-hotplug eth0\niface eth0 inet static\n  address ${var.private_ip}\n  netmask ${var.private_netmask}\" | sudo tee /etc/network/interfaces.d/01-eth0.cfg",
      "sudo rm /etc/network/interfaces.d/rm 50-cloud-init.cfg",
      "sudo ifdown eth0",
      "sudo ifup eth0",
      "sudo dpkg-reconfigure maas-region-controller",
      "sudo reboot"
    ]
  }
}

resource "null_resource" "maas-admin" {
  depends_on = ["null_resource.maas-packages"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo maas createadmin --username=${var.maas_admin["username"]} --email=${var.maas_admin["email"]} --password=${var.maas_admin["password"]}"
    ]
  }
}

