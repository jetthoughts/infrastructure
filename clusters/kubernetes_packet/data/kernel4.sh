#!/bin/bash -xe

sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum install yum-plugin-fastestmirror
sudo uname -a
sudo yum --enablerepo=elrepo-kernel install -y kernel-ml
sudo awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
sudo grub2-set-default 0
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

cd /boot
sudo ln -f -s initramfs-4.* initrd
sudo ln -f -s vmlinuz-4.* vmlinuz

# Docker overlay2
sudo tee /etc/sysconfig/docker-storage <<-'EOF'
# /etc/sysconfig/docker-storage
DOCKER_STORAGE_OPTIONS='--storage-driver=overlay2 --storage-opt overlay2.override_kernel_check=true'
EOF
echo "overlay" | sudo tee /etc/modules-load.d/overlay.conf
