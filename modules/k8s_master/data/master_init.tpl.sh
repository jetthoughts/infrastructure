#!/bin/bash -x

set -e

# https://coreos.com/os/docs/latest/cluster-discovery.html

export PRIVATE_IP=$(curl http://instance-data/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)

sysctl kernel.hostname=$PRIVATE_HOSTNAME

for i in `seq 5 1`
do
  sleep $[ $i * 10 ]
  docker ps && break || true
done

docker pull gcr.io/google_containers/kube-apiserver-amd64:${k8s_version} || true
docker pull gcr.io/google_containers/kube-controller-manager-amd64:${k8s_version} || true
docker pull gcr.io/google_containers/kube-scheduler-amd64:${k8s_version} || true
docker pull gcr.io/google_containers/kube-proxy-amd64:${k8s_version} || true

kubeadm init --config /etc/kubernetes/kubeadm.yml

# Allow other masters to join
# https://github.com/cookeem/kubeadm-ha#kubeadm-init
sed -i "s/,NodeRestriction//" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 10

echo -n "Waiting for apiserver to be ready..."
while ! curl --silent -f -k https://${domain}:6443/healthz > /dev/null; do
  sleep 5;
  echo -n '.';
done;
echo 'ready!'

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/rbac.yaml
#kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/rbankston/canal/15b94c829ab5c0201ca7ab831da7fe44c2708ac8/k8s-install/1.8/rbac.yaml
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/projectcalico/canal/master/k8s-install/1.7/canal.yaml
#kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/rbankston/canal/15b94c829ab5c0201ca7ab831da7fe44c2708ac8/k8s-install/1.8/canal.yaml

kubectl --kubeconfig=/etc/kubernetes/admin.conf get componentstatuses

sync
