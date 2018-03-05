#!/bin/bash -xe

export PATH="/usr/local/bin:$PATH"

if [[ -z "$PRIVATE_IP" ]]; then
  PRIVATE_IP=$(curl -s https://metadata.packet.net/metadata | jq .network.addresses[2].address -r)
fi

if [[ -z "$PRIVATE_HOSTNAME" ]]; then
  PRIVATE_HOSTNAME=$(curl -s https://metadata.packet.net/metadata | jq .hostname -r)
fi


kubeadm join --token="${k8s_token}" ${master_ip}:6443 --node-name="$PRIVATE_IP" --discovery-token-unsafe-skip-ca-verification

NODE_LABELS="${labels}"
KUBELET_PATH="/etc/kubernetes/kubelet.conf"

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
