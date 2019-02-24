#!/bin/bash -xe

echo "execute.sh"

chmod +x /tmp/terraform/*.sh

sudo /tmp/terraform/pre_init_script.sh
sudo /tmp/terraform/packages.sh
sudo /tmp/terraform/kube_packages.sh
sudo /tmp/terraform/k8s_kubelet_extra_args.sh
sudo /tmp/terraform/certificates.sh
sudo /tmp/terraform/kubeadm_config.sh
sudo /tmp/terraform/master.sh || exit
sudo /tmp/terraform/post_init.sh
sudo /tmp/terraform/admin.sh || true
sudo shutdown -r +1
