#!/bin/bash

set -xeuo pipefail

echo "cni.tpl.sh"

echo "Installing CNI addon"
export KUBECONFIG=/etc/kubernetes/admin.conf
${cni_install_script}
