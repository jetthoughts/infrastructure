resource "null_resource" "download-ca-certificate" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    master_private_ip = "${data.aws_instance.master.private_ip}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host                = "${data.aws_instance.master.private_ip}"
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
      "sudo chown centos:centos ${var.kube_conf_remote_path}",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      mkdir -p ${var.asset_path}/${var.name}  
      scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -o ProxyCommand="ssh -q -W %h:%p ${var.bastion["user"]}@${var.bastion["host"]} -p ${var.bastion["port"]} -i ${var.bastion["private_key"]}" ${data.aws_instance.master.private_ip}:${var.kube_conf_remote_path} ${var.asset_path}/${var.name}.conf
      ruby ${path.module}/data/extract_crt.rb -s ${var.asset_path}/${var.name}.conf -d ${var.asset_path}/${var.name}
CMD
  }

  provisioner "remote-exec" {
    inline = [
      "rm ${var.kube_conf_remote_path}",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      kubectl config set-cluster ${var.name}.${var.datacenter} --server="https://${data.aws_instance.master.private_ip}:6443" --certificate-authority=${var.asset_path}/${var.name}/ca.crt --embed-certs=true
      kubectl config set-context ${var.admin_email}@${var.name}.${var.datacenter} --cluster="${var.name}.${var.datacenter}" --user="${var.admin_email}" --namespace=default
CMD
  }
}
