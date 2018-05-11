#!/usr/bin/env bash

set -x

version=$1
output=$2

docker run -v ${output}:/etc/kubernetes/pki miry/kubernetes:${version} /bin/kubeadm alpha phase certs all
