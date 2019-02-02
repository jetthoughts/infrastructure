#!/bin/bash -eu

set -euo pipefail

# https://coreos.com/os/docs/latest/cluster-discovery.html

export PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)

sysctl -w kernel.hostname=$PRIVATE_HOSTNAME

for i in `seq 5 1`
do
  sleep $[ $i * 10 ]
  docker ps && break || true
done

kubeadm config images pull

kubeadm init --config /etc/kubernetes/kubeadm.yml --ignore-preflight-errors=SystemVerification

#kubeadm join --token="bootstrap_token" ${domain}:6443 --node-name="$PRIVATE_HOSTNAME" --experimental-control-plane

# Allow other masters to join
# https://github.com/cookeem/kubeadm-ha#kubeadm-init
# sed -i "s/,NodeRestriction//" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 10

echo -n "Waiting for apiserver to be ready..."
while ! curl --silent -f -k https://${domain}:6443/healthz > /dev/null; do
  sleep 5;
  echo -n '.';
done;

sync
