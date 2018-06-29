#!/bin/bash -xe

cat <<EOF | sudo tee /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=--cloud-provider=aws
EOF
