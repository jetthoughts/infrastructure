#!/bin/bash -x

echo "Installing CNI addon"
export KUBECONFIG=/etc/kubernetes/admin.conf
${cni_install_script}
