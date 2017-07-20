#!/usr/bin/env bash

# -x Print command traces before executing command.
set -x
# -e Exit immediately if a command exits with a non-zero status.
set -e

export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)

sysctl kernel.hostname=$PRIVATE_HOSTNAME

# Until merge we need skip preflight checks: https://github.com/kubernetes/kubernetes/pull/49073/files
kubeadm join --token="${k8s_token}" ${master_ip}:6443 --skip-preflight-checks

sync
