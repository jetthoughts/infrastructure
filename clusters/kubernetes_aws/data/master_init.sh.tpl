#!/usr/bin/env bash

# -x Print command traces before executing command.
set -x
# -e Exit immediately if a command exits with a non-zero status.
set -e

export PRIVATE_IP=$(curl http://instance-data/latest/meta-data/local-ipv4)

kubeadm init --token="${k8s_token}" --apiserver-advertise-address=$PRIVATE_IP --apiserver-cert-extra-sans="${domain}" --pod-network-cidr 10.244.0.0/16

# Enable OpenID Connect Authorization
sed -i "/- kube-apiserver/a\    - --oidc-issuer-url=https://accounts.google.com\n    - --oidc-username-claim=email\n    - --oidc-client-id=${google_oauth_client_id}" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 30

kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/rbac.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/canal.yaml

# Allow centos user to access the cluster
cp /etc/kubernetes/admin.conf /home/centos/admin.conf
chown centos:centos /home/centos/admin.conf

sync
