#!/usr/bin/env bash

# -x Print command traces before executing command.
set -x
# -e Exit immediately if a command exits with a non-zero status.
set -e

# Require for RexRay https://rexray.readthedocs.io/en/stable/user-guide/schedulers/#kubernetes
# Cloud https://docs.google.com/document/d/17d4qinC_HnIwrK0GHnRlD1FKkTNdN__VO4TH9-EzbIY/edit
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/20-cloud-provider-and-rexray.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--enable-controller-attach-detach=false --cloud-provider=aws"
EOF
