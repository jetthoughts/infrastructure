#!/bin/bash -xe

set -e
set -x

export PRIVATE_IP=$(curl http://instance-data/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)

sysctl kernel.hostname=$PRIVATE_HOSTNAME

KUBEADM_CONFIG="/etc/kubernetes/kubeadm.yml"

cat <<EOF > $KUBEADM_CONFIG
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
kubernetesVersion: ${k8s_version}
nodeName: $PRIVATE_HOSTNAME
token: ${k8s_token}
tokenTTL: 0h0m0s
apiServerExtraArgs:
  apiserver-count: "${cluster_size}"
  runtime-config: "api/all=true,batch/v1beta1=true"
  oidc-issuer-url: "https://accounts.google.com"
  oidc-username-claim: email
  oidc-client-id: ${google_oauth_client_id}

networking:
  podSubnet: ${k8s_pod_network_cidr}

apiServerCertSANs:
- localhost
- 127.0.0.1
- 10.96.0.1
- $PRIVATE_IP
- $PRIVATE_HOSTNAME
- ${domain}
EOF

MASTER_IPS="${master_ips}"
if [ "$MASTER_IPS" != "" ]; then
  for ipaddress in $MASTER_IPS
  do
    echo "- $ipaddress" >> $KUBEADM_CONFIG
  done
fi

ETCD_ENDPOINTS="${etcd_endpoints}"
if [ "$ETCD_ENDPOINTS" != "" ]; then
  cat <<EOF >> $KUBEADM_CONFIG
etcd:
  endpoints:
EOF

  for endpoint in $ETCD_ENDPOINTS
  do
    echo "  - $endpoint" >> $KUBEADM_CONFIG
  done
fi

sync
