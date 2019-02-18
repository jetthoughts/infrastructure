#!/bin/bash -xe

# Exit if the packages already are preinstalled via image
which kubeadm && exit 0

sudo yum update -y

# Install kernel 4 for ipvs
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm || true
sudo yum install yum-plugin-fastestmirror
sudo uname -a
sudo yum --enablerepo=elrepo-kernel install -y kernel-ml
sudo awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
sudo grub2-set-default 0
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

sync

# Docker CE

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Kubernetes Provision
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes_unstable.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64-unstable
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# https://github.com/kubernetes/kubernetes/issues/64073#issuecomment-415431323
# https://github.com/kubernetes/website/pull/2211/files
sudo setenforce 0 || true
sudo sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

sudo yum install -y docker-ce docker-ce-cli containerd.io \
                    kubeadm kubelet kubectl kubernetes-cni cri-tools \
                    ceph-common wget perf wireshark tcpdump httping sysstat \
                    ipvsadm perf tmux vim bind-utils

# Docker config
sudo mkdir -p /etc/docker
cat  <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload

kubeadm version

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
# /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

cat <<EOF | sudo tee /etc/sysctl.d/10-disable-ipv6.conf
# /etc/sysctl.d/10-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
EOF
sudo sysctl --system

sudo systemctl enable docker && sudo systemctl restart docker
sudo systemctl enable kubelet && sudo systemctl restart kubelet

docker version

echo -e "ip_vs\nip_vs_rr\nip_vs_wrr\nip_vs_sh\nnf_conntrack_ipv4" | sudo tee -a /etc/modules-load.d/99-ip_vs.conf

sudo tee /etc/sysconfig/modules/ip_vc.modules <<EOF
#!/bin/sh

#
# Load the ip vs module for load native balancers
#
/sbin/modinfo -F filename ip_vs >/dev/null 2>&1
if [ $? -eq 0 ]
then
  modprobe ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 >/dev/null 2>&1
fi
EOF

sudo chmod +x /etc/sysconfig/modules/ip_vc.modules
sudo sh /etc/sysconfig/modules/ip_vc.modules || true
