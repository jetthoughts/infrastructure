# Raspi3
variable "server_ip" {}

# https://bugs.launchpad.net/ubuntu/+source/linux-raspi2/+bug/1652270
# https://bugs.launchpad.net/ubuntu/+source/linux-raspi2/+bug/1652270/comments/44
# https://bugs.launchpad.net/ubuntu/+source/linux-firmware-raspi2/+bug/1691729
resource "null_resource" "fix-linux-firmware-issue" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-mark hold linux-raspi2 linux-image-raspi2 linux-headers-raspi2",
      "sudo dpkg-divert --divert /lib/firmware/brcm/brcmfmac43430-sdio-2.bin --package linux-firmware-raspi2 --rename --add /lib/firmware/brcm/brcmfmac43430-sdio.bin",
      "sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade",
      "sudo apt-mark unhold linux-raspi2 linux-image-raspi2 linux-headers-raspi2",
      "sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade",
      "sudo sed 's/device_tree_address.*/device_tree_address=0x02008000/g; s/^.*device_tree_end.*//g;' -i /boot/firmware/config.txt",
      "sudo reboot"
    ]
  }
}

resource "null_resource" "wifi" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y wireless-tools wpasupplicant",
      "sudo reboot"
    ]
  }
}