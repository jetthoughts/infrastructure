#!/bin/bash -xe

# https://coreos.com/os/docs/latest/cluster-discovery.html

export PATH="/usr/local/bin:$PATH"

if [[ -z "$PRIVATE_IP" ]]; then
  PRIVATE_IP=$(curl -s https://metadata.packet.net/metadata | jq .network.addresses[2].address -r)
fi

if [[ -z "$PRIVATE_HOSTNAME" ]]; then
  PRIVATE_HOSTNAME=$(curl -s https://metadata.packet.net/metadata | jq .hostname -r)
fi

for i in `seq 5 1`
do
  sleep $[ $i * 10 ]
  docker ps && break || true
done

kubeadm init --config /etc/kubernetes/kubeadm.yml

# Allow other masters to join
# https://github.com/cookeem/kubeadm-ha#kubeadm-init
sed -i "s/,NodeRestriction//" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 10

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/rbac.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml

kubectl --kubeconfig=/etc/kubernetes/admin.conf get componentstatuses

sync
