#!/bin/bash -xe

# Exit if the packages already are pre installed via image
which kubeadm && exit 0

export PATH="/usr/local/bin:$PATH"

sudo yum update -y

export ARCH="x86_64"

# Kubernetes Provision
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$ARCH
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo setenforce 0 || true

sudo yum install -y docker kubeadm kubelet kubectl kubernetes-cni \
               bind-utils \
               ceph-common # To use Rook : Persistent Storage

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat <<EOF | sudo tee /etc/sysctl.d/10-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
EOF
sudo sysctl --system

sudo systemctl enable docker && sudo systemctl start docker
sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo modprobe ip_vs
echo ip_vs | sudo tee -a /etc/modules-load.d/99-ip_vs.conf

cat <<EOF | sudo tee /etc/sysconfig/modules/ip_vc.modules
#!/bin/sh

#
# Load the ip vs module for load native balancers
#
/sbin/modinfo -F filename ip_vs >/dev/null 2>&1
if [ $? -eq 0 ]
then
        modprobe ip_vs >/dev/null 2>&1
fi

EOF

# Install Jq 1.5
sudo wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq
sudo chmod +x /usr/local/bin/jq
/usr/local/bin/jq --version

# For devicemapper clean locked resources
sudo tee /etc/cron.d/clean-docker-devicemapper-vol <<-'EOF'
*/30 * * * * root for dm in /dev/mapper/docker-*; do umount $dm 2> /dev/null ; dmsetup remove $dm 2> /dev/null ; done
EOF

sudo chmod 644 /etc/cron.d/clean-docker-devicemapper-vol

for i in `seq 5 1`
do
  sleep $[ $i * 10 ]
  docker ps && break || true
done

docker pull quay.io/calico/node:v2.6.1 || true
docker pull quay.io/coreos/flannel:v0.9.1 || true
docker pull quay.io/calico/cni:v1.11.0 || true
