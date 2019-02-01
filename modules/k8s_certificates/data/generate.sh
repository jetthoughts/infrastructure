#!/usr/bin/env bash

set -x

name=$1
shift
version=$1
shift
output=$1
shift
sans=$*

docker run --rm -v $output/pki:/etc/kubernetes/pki miry/kubernetes:$version \
       /bin/kubeadm init phase certs all --apiserver-cert-extra-sans "${sans}"
docker run --rm -v $output:/etc/kubernetes miry/kubernetes:$version \
       /bin/kubeadm init phase kubeconfig admin
docker run --rm -v $output:/etc/kubernetes miry/kubernetes:$version \
       sh -c "/bin/kubeadm alpha kubeconfig user --client-name=\"${name}\" 2>/dev/null" > $output/user.conf
