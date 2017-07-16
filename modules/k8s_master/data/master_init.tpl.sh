#!/usr/bin/env bash

set -e
set -x

export PRIVATE_IP=$(curl http://instance-data/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)

sysctl kernel.hostname=$PRIVATE_HOSTNAME

kubeadm init --token="${k8s_token}" --apiserver-advertise-address=$PRIVATE_IP --apiserver-cert-extra-sans="${domain}" --pod-network-cidr="${k8s_pod_network_cidr}" --kubernetes-version="${k8s_version}"

# Enable OpenID Connect Authorization
sed -i "/- kube-apiserver/a\    - --oidc-issuer-url=https://accounts.google.com\n    - --oidc-username-claim=email\n    - --oidc-client-id=${google_oauth_client_id}" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 10

# Network CNI Addon
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/rbac.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/canal.yaml

# Allow centos user to access the cluster
cp /etc/kubernetes/admin.conf /home/centos/admin.conf
chown centos:centos /home/centos/admin.conf

sync
