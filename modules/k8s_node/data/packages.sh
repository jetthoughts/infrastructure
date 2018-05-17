#!/usr/bin/env bash

# -x Print command traces before executing command.
set -x
# -e Exit immediately if a command exits with a non-zero status.
set -e

# Exit if the packages already are preinstalled via image
which kubeadm && exit 0

sudo yum update -y

# Kubernetes Provision
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes_unstable.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64-unstable
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo setenforce 0 || true

sudo yum install -y docker kubeadm kubelet kubectl kubernetes-cni \
               ceph-common # To use Rook : Persistent Storage

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat <<EOF | sudo tee /etc/sysctl.d/10-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
EOF
sudo sysctl --system

sudo systemctl enable docker && sudo systemctl start docker
sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo modprobe ip_vs
echo ip_vs | sudo tee -a /etc/modules-load.d/99-ip_vs.conf

cat <<EOF | sudo tee /etc/sysconfig/modules/ip_vc.modules
#!/bin/sh

#
# Load the ip vs module for load native balancers
#
/sbin/modinfo -F filename ip_vs >/dev/null 2>&1
if [ $? -eq 0 ]
then
  modprobe ip_vs >/dev/null 2>&1
fi

EOF
