# Ubuntu on Raspberry Pi 3

# Terraform documentation
#  * Provisioner null_resource: https://www.terraform.io/docs/provisioners/null_resource.html
#  * Provisioner Connections: https://www.terraform.io/docs/provisioners/null_resource.html

# Ubuntu issues:
# https://bugs.launchpad.net/ubuntu/+source/linux-raspi2/+bug/1652270
# https://bugs.launchpad.net/ubuntu/+source/linux-raspi2/+bug/1652270/comments/44
# https://bugs.launchpad.net/ubuntu/+source/linux-firmware-raspi2/+bug/1691729
resource "null_resource" "upgrade-packages" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-mark hold linux-raspi2 linux-image-raspi2 linux-headers-raspi2",
      "sudo dpkg-divert --divert /lib/firmware/brcm/brcmfmac43430-sdio-2.bin --package linux-firmware-raspi2 --rename --add /lib/firmware/brcm/brcmfmac43430-sdio.bin",
      "sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y",
      "sudo apt-mark unhold linux-raspi2 linux-image-raspi2 linux-headers-raspi2",
      "sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y",
      "sudo sed 's/device_tree_address.*/device_tree_address=0x02008000/g; s/^.*device_tree_end.*//g;' -i /boot/firmware/config.txt",
      "sudo reboot",
    ]
  }
}

# Ubuntu reference for hostnamectl: http://manpages.ubuntu.com/manpages/trusty/man1/hostnamectl.1.html
resource "null_resource" "set-hostname" {
  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.server_hostname}",
      "echo '127.0.0.1 ${var.server_hostname}' | sudo tee -a /etc/hosts",
      "sudo reboot",
    ]
  }
}

# https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=141834
# https://medium.com/a-swift-misadventure/how-to-setup-your-raspberry-pi-2-3-with-ubuntu-16-04-without-cables-headlessly-9e3eaad32c01
resource "null_resource" "wifi" {
  depends_on = ["null_resource.upgrade-packages"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y wireless-tools wpasupplicant",
      "cd /lib/firmware/brcm/",
      "sudo wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.bin",
      "sudo wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.txt",
      "echo \"allow-hotplug wlan0\niface wlan0 inet dhcp\nwpa-conf /etc/wpa_supplicant/wpa_supplicant.conf\" | sudo tee /etc/network/interfaces.d/10-wlan.cfg",
      "echo \"network={\\nssid=\\\"${var.wlan_ssid}\\\"\\npsk=\\\"${var.wlan_psk}\\\"\\n}\" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf",
      "sudo reboot",
    ]
  }
}

# Monitoring netdata
# https://my-netdata.io/
resource "null_resource" "monitoring" {
  depends_on = ["null_resource.wifi"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -Ss https://my-netdata.io/kickstart.sh > netdata.sh",
      "sudo bash netdata.sh --non-interactive",
    ]
  }
}
