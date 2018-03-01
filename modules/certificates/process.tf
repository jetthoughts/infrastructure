resource "null_resource" "download" {
  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    type = "${var.host_connection["type"]}"
    user = "${var.host_connection["user"]}"
    host = "${var.host_connection["host"]}"
    private_key = "${file("${var.host_connection["private_key"]}")}"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "ls /etc/kubernetes/admin.conf",
      "while [ ! -f /etc/kubernetes/admin.conf ] ; do tail -n 40 /var/log/cloud-init-output.log; sleep 30; date; done",
    ]
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "sudo cp /etc/kubernetes/admin.conf ${var.kube_conf_remote_path}",
      "sudo cp -r /etc/kubernetes ${var.kube_conf_remote_path}",
      "sudo chown ${var.host_connection["user"]}:${var.host_connection["user"]} -R ${var.kube_conf_remote_path}",
      "ls -la ${var.kube_conf_remote_path}",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      mkdir -p ${var.asset_path}/${var.name}

      scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i "${var.host_connection["private_key"]}" ${var.host_connection["user"]}@${var.host_connection["host"]}:${var.kube_conf_remote_path}/admin.conf ${var.asset_path}/${var.name}.conf

      scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i "${var.host_connection["private_key"]}" -r ${var.host_connection["user"]}@${var.host_connection["host"]}:${var.kube_conf_remote_path}/kubernetes ${var.asset_path}/${var.name}

      ruby ${path.module}/data/extract_crt.rb -s ${var.asset_path}/${var.name}.conf -d ${var.asset_path}/${var.name}
CMD
  }

  provisioner "remote-exec" {
    inline = [
      "rm -fr ${var.kube_conf_remote_path}/kubernetes",
      "rm ${var.kube_conf_remote_path}/admin.conf",
    ]
  }
}
