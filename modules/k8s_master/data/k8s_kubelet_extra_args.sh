#!/bin/bash -xe

# Require for RexRay https://rexray.readthedocs.io/en/stable/user-guide/schedulers/#kubernetes
# Cloud https://docs.google.com/document/d/17d4qinC_HnIwrK0GHnRlD1FKkTNdN__VO4TH9-EzbIY/edit
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/20-cloud-provider-and-rexray.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--enable-controller-attach-detach=false --cloud-provider=aws --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice --node-labels=node-role.kubernetes.io/master="
EOF

sudo systemctl daemon-reload
