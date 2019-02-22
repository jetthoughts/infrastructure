# Ubuntu on Raspberry Pi 3

# Terraform documentation
#  * Provisioner null_resource: https://www.terraform.io/docs/provisioners/null_resource.html
#  * Provisioner Connections: https://www.terraform.io/docs/provisioners/null_resource.html

# Ubuntu issues:
# https://bugs.launchpad.net/ubuntu/+source/linux-raspi2/+bug/1652270
# https://bugs.launchpad.net/ubuntu/+source/linux-raspi2/+bug/1652270/comments/44
# https://bugs.launchpad.net/ubuntu/+source/linux-firmware-raspi2/+bug/1691729
resource "null_resource" "packages" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
<<<<<<< HEAD
    private_key = "${file(var.private_key_path)}"
=======
    private_key = "${file("~/.ssh/id_rsa")}"
>>>>>>> Format example
    host        = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
<<<<<<< HEAD
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent netfilter-persistent",
      "sudo shutdown -r +1",
    ]
  }
}

resource "null_resource" "zram" {
  depends_on = ["null_resource.packages"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = "${var.server_ip}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "data/zram"
    destination = "/tmp/zram"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/zram | sudo tee /etc/rc.local",
      "sudo bash /tmp/zram",
=======
      // "sudo apt-mark hold linux-raspi2 linux-image-raspi2 linux-headers-raspi2",
      "sudo dpkg-divert --divert /lib/firmware/brcm/brcmfmac43430-sdio-2.bin --package linux-firmware-raspi2 --rename --add /lib/firmware/brcm/brcmfmac43430-sdio.bin",

      "sudo apt-get update && sudo apt-get upgrade -y",

      // "sudo apt-mark unhold linux-raspi2 linux-image-raspi2 linux-headers-raspi2",
      // "sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y",
      // "sudo sed 's/device_tree_address.*/device_tree_address=0x02008000/g; s/^.*device_tree_end.*//g;' -i /boot/firmware/config.txt",
>>>>>>> Format example
      "sudo shutdown -r +1",
    ]
  }
}

# Ubuntu reference for hostnamectl: http://manpages.ubuntu.com/manpages/trusty/man1/hostnamectl.1.html
resource "null_resource" "hostname" {
  depends_on = ["null_resource.packages", "null_resource.zram"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
<<<<<<< HEAD
    private_key = "${file(var.private_key_path)}"
=======
    private_key = "${file("~/.ssh/id_rsa")}"
>>>>>>> Format example
    host        = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.server_hostname}",
      "echo '127.0.0.1 ${var.server_hostname}' | sudo tee -a /etc/hosts",
      "sudo shutdown -r +1",
    ]
  }
}

# https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=141834
# https://medium.com/a-swift-misadventure/how-to-setup-your-raspberry-pi-2-3-with-ubuntu-16-04-without-cables-headlessly-9e3eaad32c01
resource "null_resource" "networking" {
  depends_on = ["null_resource.hostname"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
<<<<<<< HEAD
    private_key = "${file(var.private_key_path)}"
=======
    private_key = "${file("~/.ssh/id_rsa")}"
>>>>>>> Format example
    host        = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -yq wireless-tools wpasupplicant",
      "echo \"network:\\n  version: 2\\n  wifis:\\n    wlan0:\\n      dhcp4: yes\\n      access-points:\\n        \\\"${var.wlan_ssid}\\\":\\n          password: \\\"${var.wlan_psk}\\\"\\n\" | sudo tee /etc/netplan/50-wifi.yaml",
      "echo \"network:\\n  version: 2\\n  ethernets:\\n    eth1:\\n      dhcp4: true\\n\" | sudo tee /etc/netplan/50-eth1.yaml",
      "sudo netplan --debug apply",
      "sudo shutdown -r +1",
    ]
  }
}

# Monitoring netdata
# https://my-netdata.io/
resource "null_resource" "monitoring" {
  count = var.monitoring_disabled ? 0 : 1
  depends_on = ["null_resource.networking"]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = "${var.server_ip}"
<<<<<<< HEAD
    private_key = "${file(var.private_key_path)}"
=======
    private_key = "${file("~/.ssh/id_rsa")}"
>>>>>>> Format example
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -yq install autoconf-archive automake gcc libmnl-dev make pkg-config python-pymongo python-yaml uuid-dev zlib1g-dev",
      "curl -Ss https://my-netdata.io/kickstart.sh > netdata.sh",
      "sudo bash netdata.sh --non-interactive",
    ]
  }
}

output "netdata" {
  value = "http://${var.server_ip}:19999"
}
