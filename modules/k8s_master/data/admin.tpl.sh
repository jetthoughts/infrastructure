#!/bin/bash -x

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl create clusterrolebinding cluster-admin-${admin_email} --clusterrole=cluster-admin --user=${admin_email}
kubectl create clusterrolebinding admin-${admin_email} --clusterrole=admin --user=${admin_email}
