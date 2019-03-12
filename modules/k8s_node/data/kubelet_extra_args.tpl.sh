#!/bin/bash -xe

TAINT_ARGS=
if [[ ! -z "${node_taints}" ]]; then
  TAINT_ARGS="--register-node=true --register-with-taints=${node_taints}"
fi

PUBLIC_IP=$(curl http://instance-data/latest/meta-data/public-ipv4)

LABELS_ARGS="--node-labels=kubernetes.io/public-ipv4=$PUBLIC_IP"
if [[ ! -z "${node_labels}" ]]; then
  LABELS_ARGS="$LABELS_ARGS,${node_labels}"
fi

cat <<EOF | sudo tee /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=${kubelet_extra_args} $TAINT_ARGS $LABELS_ARGS
EOF
