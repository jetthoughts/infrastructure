
# https://github.com/madeden/blogposts/blob/master/k8s-gpu-cluster/10-install-maas.md
resource "null_resource" "maas-packages" {

  depends_on = ["null_resource.wifi"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }
  


  provisioner "remote-exec" {
    inline = [
      "sudo apt-add-repository -yu ppa:maas/stable",
      "DEBIAN_FRONTEND=noninteractive sudo apt install -yqq --no-install-recommends maas bzr isc-dhcp-server wakeonlan amtterm wsmancli zram-config"
    ]
  }
}