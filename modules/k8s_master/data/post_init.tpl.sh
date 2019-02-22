#!/bin/bash

set -xeuo pipefail

echo "post_init.tpl.sh"

echo "Run post master init script"
export KUBECONFIG=/etc/kubernetes/admin.conf
${post_init_script}
