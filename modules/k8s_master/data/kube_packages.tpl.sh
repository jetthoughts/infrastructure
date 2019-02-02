#!/usr/bin/env bash

# -x Print command traces before executing command.
set -x
# -e Exit immediately if a command exits with a non-zero status.
set -e

KUBE_VERSION="${kube_version}"
if [ "$KUBE_VERSION" = "" ]; then
  exit 0
fi

version=$(kubeadm version -o short)

if [[ "$version" = "$KUBE_VERSION" ]]; then
  exit 0
fi

sudo systemctl stop kubelet

sudo wget -q -O $(which kubeadm) https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubeadm
sudo wget -q -O $(which kubectl) https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubectl
sudo wget -q -O $(which kubelet) https://storage.googleapis.com/kubernetes-release/release/$KUBE_VERSION/bin/linux/amd64/kubelet

sudo systemctl restart kubelet
sudo systemctl enable crio
sudo systemctl restart crio
