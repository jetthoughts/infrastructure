#!/usr/bin/env bash

set -x

name=$1
shift
version=$1
shift
output=$1
shift
sans=$*

docker run --rm -v $output/pki:/etc/kubernetes/pki miry/kubernetes:$version /bin/kubeadm alpha phase certs all --apiserver-cert-extra-sans "${sans}"

readonly kubeadm="docker run --rm -v $output:/etc/kubernetes miry/kubernetes:$version /bin/kubeadm"

$kubeadm alpha phase certs ca
$kubeadm alpha phase certs etcd-ca
$kubeadm alpha phase certs sa
$kubeadm alpha phase certs front-proxy-ca

$kubeadm alpha phase kubeconfig admin

docker run --rm -v $output:/etc/kubernetes miry/kubernetes:$version \
       sh -c '/bin/kubeadm alpha phase kubeconfig user --client-name="user" 2>/dev/null' > $output/user.conf


docker run --rm -v $(pwd)/assets/v111:/etc/kubernetes miry/kubernetes:$version \
       sh -c '/bin/kubeadm alpha phase kubeconfig user --client-name="user" 2>/dev/null' > $(pwd)/assets/v111/user.conf
