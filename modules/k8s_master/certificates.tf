resource "null_resource" "download-ca-certificate" {
  count      = "${length(concat(aws_instance.masters.*.private_ip, list(""))) > 0 ? 1 : 0}"
  depends_on = ["aws_instance.masters"]

  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    master_private_ip = "${aws_instance.masters.0.private_ip}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host                = "${aws_instance.masters.0.private_ip}"
    user                = "centos"
    private_key         = "${file("${var.asset_path}/${var.ssh_key_name}")}"
    bastion_host        = "${var.bastion["host"]}"
    bastion_user        = "${var.bastion["user"]}"
    bastion_port        = "${var.bastion["port"]}"
    bastion_private_key = "${file(var.bastion["private_key"])}"
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
      "sudo chown centos:centos -R ${var.kube_conf_remote_path}",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      mkdir -p ${var.asset_path}/${var.name}
      echo "${self.triggers.master_private_ip}"
      scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -o ProxyCommand="ssh -q -W %h:%p ${var.bastion["user"]}@${var.bastion["host"]} -p ${var.bastion["port"]} -i ${var.bastion["private_key"]}" -i "${var.asset_path}/${var.ssh_key_name}" centos@${aws_instance.masters.0.private_ip}:${var.kube_conf_remote_path}/admin.conf ${var.asset_path}/${var.name}.conf
      scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -o ProxyCommand="ssh -q -W %h:%p ${var.bastion["user"]}@${var.bastion["host"]} -p ${var.bastion["port"]} -i ${var.bastion["private_key"]}" -i "${var.asset_path}/${var.ssh_key_name}" -r centos@${aws_instance.masters.0.private_ip}:${var.kube_conf_remote_path}/kubernetes ${var.asset_path}/${var.name}
      ruby ${path.module}/data/extract_crt.rb -s ${var.asset_path}/${var.name}.conf -d ${var.asset_path}/${var.name}
CMD
  }

  provisioner "remote-exec" {
    inline = [
      "rm -fr ${var.kube_conf_remote_path}/kubernetes",
      "rm ${var.kube_conf_remote_path}/admin.conf",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      kubectl config set-cluster ${var.name}.${var.datacenter} --server="https://${aws_instance.masters.0.private_ip}:6443" --certificate-authority=${var.asset_path}/${var.name}/ca.crt --embed-certs=true
      kubectl config set-context ${var.admin_email}@${var.name}.${var.datacenter} --cluster="${var.name}.${var.datacenter}" --user="${var.admin_email}" --namespace=default
      cp -r ${var.asset_path}/${var.name}/kubernetes/pki/* ${var.certs_path}
CMD
  }
}
