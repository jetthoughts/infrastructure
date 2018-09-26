#!/bin/bash -xe

TAINT_ARGS=
if [[ ! -z "${node_taints}" ]]; then
  TAINT_ARGS="--register-node=true --register-with-taints=${node_taints}"
fi

LABELS_ARGS=
if [[ ! -z "${node_taints}" ]]; then
  LABELS_ARGS="--node-labels=${node_labels}"
fi

cat <<EOF | sudo tee /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=${kubelet_extra_args} --authentication-token-webhook $TAINT_ARGS $LABELS_ARGS
EOF
