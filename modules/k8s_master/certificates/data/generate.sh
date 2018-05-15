#!/usr/bin/env bash

set -x

name=$1
shift
version=$1
shift
output=$1
shift
sans=$*

docker run --rm -v $output:/etc/kubernetes/pki miry/kubernetes:$version /bin/kubeadm alpha phase certs all --apiserver-cert-extra-sans "${sans}"
docker run --rm -v $output:/etc/kubernetes/pki miry/kubernetes:$version /bin/kubeadm alpha phase kubeconfig user --client-name="${name}"
