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

docker pull k8s.gcr.io/pause:3.1 || true
docker pull k8s.gcr.io/etcd:3.2.24 || true
docker pull k8s.gcr.io/coredns:1.2.4 || true
docker pull k8s.gcr.io/kube-scheduler:${kube_version} || true
docker pull k8s.gcr.io/kube-controller-manager:${kube_version} || true
docker pull k8s.gcr.io/kube-apiserver:${kube_version} || true
docker pull k8s.gcr.io/kube-proxy:${kube_version} || true

kubeadm init --config /etc/kubernetes/kubeadm.yml --ignore-preflight-errors=SystemVerification

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
