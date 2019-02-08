#!/bin/bash

set -xeuo pipefail

echo "master_init.tpl.sh"
# https://coreos.com/os/docs/latest/cluster-discovery.html

export PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)

sysctl -w kernel.hostname=$PRIVATE_HOSTNAME

for i in `seq 5 1`
do
  sleep $[ $i * 10 ]
  docker ps && break || true
done

kubeadm config images pull --config /etc/kubernetes/kubeadm.yml

join=""
ips=$(dig ${domain} +short A)
for ip in $ips ; do
  echo $ip
  curl --silent -f -k https://$ip:6443/healthz > /dev/null && join="join"
done

echo $join

if [ "$join" = "" ]; then
  kubeadm init --config /etc/kubernetes/kubeadm.yml
else
  kubeadm init phase certs all --config /etc/kubernetes/kubeadm.yml

    export ETCDCTL_ENDPOINTS="${etcd_endpoints}"

    kubeadm init phase certs all --config /etc/kubernetes/kubeadm.yml

    etcdcli="docker run --net=host -v /etc/kubernetes/pki/etcd:/etc/kubernetes/pki/etcd -e ETCDCTL_API=3 -it --rm k8s.gcr.io/etcd:3.3.10 etcdctl --endpoints=$ETCDCTL_ENDPOINTS --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt  --key=/etc/kubernetes/pki/etcd/peer.key"

    members=$($etcdcli member list)
    echo $members

    member_id=$(echo "$members" | grep "$PRIVATE_HOSTNAME" | cut -f1 -d',' || echo -n)
    echo $member_id

    if "$member_id" != "" ]; then
      $etcdcli member remove $member_id
    fi

  kubeadm join --token="${kubeadm_bootstrap_token}" ${domain}:6443 --apiserver-advertise-address="$PRIVATE_IP" --node-name="$PRIVATE_HOSTNAME" --experimental-control-plane --discovery-token-unsafe-skip-ca-verification -v7
fi

# kubeadm join --token="kubeadm_bootstrap_token" ${domain}:6443 --node-name="$PRIVATE_HOSTNAME" --experimental-control-plane

# Allow other masters to join
# https://github.com/cookeem/kubeadm-ha#kubeadm-init
# sed -i "s/,NodeRestriction//" /etc/kubernetes/manifests/kube-apiserver.yaml

sleep 10


echo -n "Waiting for apiserver to be ready..."
while ! curl --silent -f -k https://$PRIVATE_HOSTNAME:6443/healthz > /dev/null; do
  sleep 5
  echo -n '.'
done
echo

sync
