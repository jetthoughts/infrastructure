#!/bin/bash -xeu

set -euo pipefail

echo "kubeadm_config.tpl.sh"
# kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=1.14.0-alpha.2

set -euo pipefail

export PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)

KUBEADM_CONFIG="/etc/kubernetes/kubeadm.yml"

# https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta1
cat <<EOF > $KUBEADM_CONFIG
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration

bootstrapTokens:
  - token: ${bootstrap_token}
    description: "node join token"
    ttl: "0h0m0s"
nodeRegistration:
  name: $PRIVATE_HOSTNAME
  kubeletExtraArgs:
    cgroup-driver: systemd
    cloud-provider: external
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration

cgroupDriver: systemd
imageMinimumGCAge: 5m0s
cpuCFSQuota: false
enforceNodeAllocatable: []
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%

---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration

# clusterName: "${name}"
networking:
  # serviceSubnet: "${service_network_cidr}"
  podSubnet: "${pod_network_cidr}"
kubernetesVersion: ${kube_version}
controlPlaneEndpoint: "${internal_domain}:6443"

apiServer:
  extraArgs:
    # authorization-mode: "Node,RBAC"
    apiserver-count: "${cluster_size}"
    # runtime-config: "api/all=true,batch/v1beta1=true"
    oidc-issuer-url: "https://accounts.google.com"
    oidc-username-claim: email
    oidc-client-id: ${google_oauth_client_id}
    etcd-prefix: "${etcd_prefix}"
    # cloud-provider: aws

  certSANs:
    - localhost
    - 127.0.0.1
    - 10.96.0.1
    - $PRIVATE_IP
    - $PRIVATE_HOSTNAME
    - ${domain}
    - ${internal_domain}
EOF

MASTER_IPS="${master_ips}"
if [ "$MASTER_IPS" != "" ]; then
  for ipaddress in $MASTER_IPS
  do
    echo "    - $ipaddress" >> $KUBEADM_CONFIG
  done
fi

ETCD_ENDPOINTS="${etcd_endpoints}"
if [ "$ETCD_ENDPOINTS" != "" ]; then
  cat <<EOF >> $KUBEADM_CONFIG
etcd:
  external:
    endpoints:
EOF

  for endpoint in $ETCD_ENDPOINTS
  do
    echo "      - $endpoint" >> $KUBEADM_CONFIG
  done
fi

sync

cat <<EOF
---
controllerManagerExtraArgs:
  # DEPRECATED: Would be removed in next version
  cloud-provider: "aws"
  configure-cloud-routes: "false"
  horizontal-pod-autoscaler-use-rest-clients: "false"
  horizontal-pod-autoscaler-downscale-delay: "15m0s"

kubeletConfiguration:
  baseConfig:
    authentication:
      webhook:
        enabled: true
    cgroupDriver: /systemd/system.slice

kubeProxy:
  config:
    mode: ipvs
    conntrack:
      max: null
      maxPerCore: 1048576
      min: 524288
      tcpCloseWaitTimeout: 0h10m0s
      tcpEstablishedTimeout: 1h0m0s

---
# https://godoc.org/k8s.io/kubelet/config/v1beta1#KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
evictionHard:
    memory.available:  "300Mi"
cloudProvider: aws
cgroupDriver: systemd
runtimeCgroups: /systemd/system.slice
kubeletCgroups: /systemd/system.slice

EOF
