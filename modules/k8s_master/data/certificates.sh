#!/usr/bin/env bash

set -x

# Check that we have certificates
[ -d /tmp/terraform/pki ] || exit 0

mkdir -p /etc/kubernetes/
cp -r /tmp/terraform/pki /etc/kubernetes
ls -la /etc/kubernetes/pki

openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt
