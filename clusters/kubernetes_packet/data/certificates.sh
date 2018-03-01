#!/bin/bash -xe

# Check that we have certificates
[ -d /tmp/terraform/pki ] || exit 0

mkdir -p /etc/kubernetes/
cp -r /tmp/terraform/pki /etc/kubernetes
ls -la /etc/kubernetes/pki
