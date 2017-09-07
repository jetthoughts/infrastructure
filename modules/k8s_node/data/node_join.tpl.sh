#!/usr/bin/env bash

# -x Print command traces before executing command.
set -x
# -e Exit immediately if a command exits with a non-zero status.
set -e

export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)

sysctl kernel.hostname=$PRIVATE_HOSTNAME

kubeadm join --token="${k8s_token}" ${master_ip}:6443 --node-name="$PRIVATE_HOSTNAME"

export NODE_LABELS="${labels}"

if [ "$NODE_LABELS" != "" ]; then
  sleep 30
  kubectl --kubeconfig=/etc/kubernetes/kubelet.conf label node/$PRIVATE_HOSTNAME $NODE_LABELS
fi

sync
