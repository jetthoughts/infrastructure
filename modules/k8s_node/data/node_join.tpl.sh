#!/usr/bin/env bash

# -x Print command traces before executing command.
set -x
# -e Exit immediately if a command exits with a non-zero status.
set -e

export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)

sysctl kernel.hostname=$PRIVATE_HOSTNAME

for i in {1..100}
do
  docker ps && break || true
  sleep $i
done

# TODO: Send notification if it failed to node join
docker ps

docker pull gcr.io/google_containers/kube-proxy-amd64:${kube_version} || true

kubeadm join --token="${kube_token}" ${master_ip}:6443 --node-name="$PRIVATE_HOSTNAME" --discovery-token-unsafe-skip-ca-verification

export NODE_LABELS="${node_labels}"
export KUBELET_PATH="/etc/kubernetes/kubelet.conf"

sleep 30

counter=30
while [[ ! -f $KUBELET_PATH ]] && [[ $counter -ge 1 ]]; do
  sleep 5
  counter=$[ $counter -1 ]
  echo -n .
done

if [ "$NODE_LABELS" != "" ]; then
  kubectl --kubeconfig=$KUBELET_PATH label node/$PRIVATE_HOSTNAME $NODE_LABELS
fi

# If master_ip is the host kubeadm resolve it and use ip. It revert such changes
kubectl --kubeconfig=/etc/kubernetes/kubelet.conf config set-cluster default-cluster --server="https://${master_ip}:6443"

sync
