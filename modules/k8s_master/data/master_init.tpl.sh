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

kubeadm init --config /etc/kubernetes/kubeadm.yml --ignore-preflight-errors=SystemVerification

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
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/canal/canal.yaml

kubectl get componentstatuses

sync
