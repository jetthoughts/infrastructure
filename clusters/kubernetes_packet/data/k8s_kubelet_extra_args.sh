#!/bin/bash -xe

export PATH="/usr/local/bin:$PATH"

if [[ -z "$PRIVATE_IP" ]]; then
  PRIVATE_IP=$(curl -s https://metadata.packet.net/metadata | jq .network.addresses[2].address -r)
fi

# https://github.com/kubernetes/kubeadm/issues/584#issuecomment-349335274
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/20-hostname-overide.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--hostname-override $PRIVATE_IP"
EOF

sudo systemctl daemon-reload
