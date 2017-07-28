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

kubeadm init --token="${k8s_token}" --apiserver-advertise-address=$PRIVATE_IP --apiserver-cert-extra-sans="${domain}" --pod-network-cidr="${k8s_pod_network_cidr}" --kubernetes-version="${k8s_version}" --skip-token-print --token-ttl 0

# Enable OpenID Connect Authorization
sed -i "/- kube-apiserver/a\    - --oidc-issuer-url=https://accounts.google.com\n    - --oidc-username-claim=email\n    - --oidc-client-id=${google_oauth_client_id}" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 10

# Network CNI Addon
# Until merge https://github.com/projectcalico/canal/pull/90 to fix next:
#Jul 28 11:00:47 ip-10-0-10-141.ec2.internal dockerd-current[2069]: 2017-07-28 11:00:47.435 [INFO][26] syncer.go 613: Needs resync: map[NetworkPolicy:true HostConfig:true IPPool:true CalicoReadyState:true Pod:true SystemNetworkPolicy:true GlobalConfig:true Node:true Namespace:true]
#Jul 28 11:00:47 ip-10-0-10-141.ec2.internal dockerd-current[2069]: 2017-07-28 11:00:47.435 [INFO][26] syncer.go 617: Syncing Namespaces
#Jul 28 11:00:47 ip-10-0-10-141.ec2.internal dockerd-current[2069]: 2017-07-28 11:00:47.438 [INFO][26] syncer.go 652: Syncing NetworkPolicy
#Jul 28 11:00:47 ip-10-0-10-141.ec2.internal dockerd-current[2069]: 2017-07-28 11:00:47.441 [INFO][26] syncer.go 675: Syncing SystemNetworkPolicy
#Jul 28 11:00:47 ip-10-0-10-141.ec2.internal dockerd-current[2069]: 2017-07-28 11:00:47.442 [WARNING][26] syncer.go 678: Error querying SystemNetworkPolicies during snapshot, retrying: User "system:serviceaccount:kube-system:canal" cannot list systemnetworkpolicies.alpha.projectcalico.org in the namespace "kube-system". (get systemnetworkpolicies.alpha.projectcalico.org)

#kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/rbac.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/treacher/canal/01733038736324b5c0e3da1aa23ca8c0244dd2b9/k8s-install/1.6/rbac.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.6/canal.yaml

sync
