#!/usr/bin/env bash

set -e
set -x

export PRIVATE_IP=$(curl http://instance-data/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)

sysctl kernel.hostname=$PRIVATE_HOSTNAME

# Pre pull images for canal
docker pull quay.io/calico/node:v1.3.0
docker pull quay.io/calico/cni:v1.9.1
docker pull quay.io/coreos/flannel:v0.8.0

kubeadm init --token="${k8s_token}" \
             --apiserver-advertise-address=$PRIVATE_IP \
             --apiserver-cert-extra-sans="${domain}" \
             --pod-network-cidr="${k8s_pod_network_cidr}" \
             --kubernetes-version="${k8s_version}" \
             --skip-token-print \
             --token-ttl 0

# Enable OpenID Connect Authorization
sed -i "/- kube-apiserver/a\    - --oidc-issuer-url=https://accounts.google.com\n    - --oidc-username-claim=email\n    - --oidc-client-id=${google_oauth_client_id}" /etc/kubernetes/manifests/kube-apiserver.yaml

# Enable CronJob resources
sed -i "/- kube-apiserver/a\    - --runtime-config=batch/v2alpha1=true" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 10

kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/rbac.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/canal.yaml

sync
