#!/usr/bin/env bash

set -x
set -e

ETCD_VER=v3.2.9

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/coreos/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download && mkdir -p /tmp/etcd-download


curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download --strip-components=1

mv /tmp/etcd-download/etcd /tmp/etcd-download/etcdctl /usr/local/bin/

rm -rf /tmp/etcd-download

/usr/local/bin/etcd --version

ETCDCTL_API=3 /usr/local/bin/etcdctl version

mkdir /var/lib/etcd
mkdir /etc/etcd
groupadd -r etcd
useradd -r -g etcd -d /var/lib/etcd -s /sbin/nologin -c "etcd user" etcd
chown -R etcd:etcd /var/lib/etcd

cat << EOF > /usr/lib/systemd/system/etcd.service
[Unit]
Description=etcd service
Documentation=https://github.com/coreos
After=network.target

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
User=etcd
ExecStart=/usr/local/bin/etcd -config-file /etc/etcd/etcd.yml
LimitNOFILE=65536
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl enable etcd
