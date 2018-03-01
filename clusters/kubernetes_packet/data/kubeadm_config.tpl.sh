#!/bin/bash -xe

export PATH="/usr/local/bin:$PATH"

if [[ -z "$PRIVATE_IP" ]]; then
  PRIVATE_IP=$(curl -s https://metadata.packet.net/metadata | jq .network.addresses[2].address -r)
  PUBLIC_IP=$(curl -s https://metadata.packet.net/metadata | jq .network.addresses[0].address -r)
fi

if [[ -z "$PRIVATE_HOSTNAME" ]]; then
  PRIVATE_HOSTNAME=$(curl -s https://metadata.packet.net/metadata | jq .hostname -r)
fi

KUBEADM_CONFIG="/etc/kubernetes/kubeadm.yml"

# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file
cat <<EOF > $KUBEADM_CONFIG
featureGates:
 CoreDNS: true
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
kubernetesVersion: ${k8s_version}
nodeName: $PRIVATE_IP
apiServerExtraArgs:
  feature-gates: SupportIPVSProxyMode=true
api:
  advertiseAddress: $PRIVATE_IP
  bindPort: 6443
token: ${k8s_token}
tokenTTL: 0h0m0s
apiServerExtraArgs:
  apiserver-count: "${cluster_size}"
  runtime-config: "api/all=true,batch/v1beta1=true"
EOF

OIDC_CLIENT_ID="${google_oauth_client_id}"
if [ "$OIDC_CLIENT_ID" != "" ]; then
  cat <<EOF >> $KUBEADM_CONFIG
  oidc-issuer-url: "https://accounts.google.com"
  oidc-username-claim: email
  oidc-client-id: $OIDC_CLIENT_ID
EOF
fi

POD_SUBNET="${k8s_pod_network_cidr}"
if [ "$POD_SUBNET" != "" ]; then
  cat <<EOF >> $KUBEADM_CONFIG
networking:
  podSubnet: $POD_SUBNET
EOF
fi

cat <<EOF >> $KUBEADM_CONFIG
apiServerCertSANs:
- localhost
- 127.0.0.1
- 10.96.0.1
- $PRIVATE_IP
- $PUBLIC_IP
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
