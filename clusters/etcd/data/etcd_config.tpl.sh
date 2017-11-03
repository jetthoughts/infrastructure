#!/usr/bin/env bash

export PRIVATE_IP=$(curl http://instance-data/latest/meta-data/local-ipv4)
export PRIVATE_HOSTNAME=$(curl http://instance-data/latest/meta-data/hostname)
export PROTOCOL="${ssl == "true" ? "https" : "http"}"

cat <<EOF > /etc/etcd/etcd.yml
# This is the configuration file for the etcd server.

name: '$PRIVATE_HOSTNAME'

# Path to the data directory.
data-dir: /var/lib/etcd

# Path to the dedicated wal directory.
wal-dir:

# Number of committed transactions to trigger a snapshot to disk.
snapshot-count: 10000

# Time (in milliseconds) of a heartbeat interval.
heartbeat-interval: 100

# Time (in milliseconds) for an election to timeout.
election-timeout: 1000

# Raise alarms when backend size exceeds the given quota. 0 means use the
# default quota.
quota-backend-bytes: 0

# List of comma separated URLs to listen on for peer traffic.
listen-peer-urls: $PROTOCOL://localhost:2380,$PROTOCOL://$PRIVATE_IP:2380

# List of comma separated URLs to listen on for client traffic.
listen-client-urls: $PROTOCOL://localhost:2379,$PROTOCOL://localhost:4001,$PROTOCOL://$PRIVATE_IP:2379,$PROTOCOL://$PRIVATE_IP:4001

# Maximum number of snapshot files to retain (0 is unlimited).
max-snapshots: 5

# Maximum number of wal files to retain (0 is unlimited).
max-wals: 5

# Comma-separated white list of origins for CORS (cross-origin resource sharing).
cors:

# List of this member's peer URLs to advertise to the rest of the cluster.
# The URLs needed to be a comma-separated list.
initial-advertise-peer-urls: $PROTOCOL://$PRIVATE_IP:2380

# List of this member's client URLs to advertise to the public.
# The URLs needed to be a comma-separated list.
advertise-client-urls: $PROTOCOL://$PRIVATE_IP:2379,$PROTOCOL://$PRIVATE_IP:4001,$PROTOCOL://$PRIVATE_HOSTNAME:2379,$PROTOCOL://$PRIVATE_HOSTNAME:4001

# Discovery URL used to bootstrap the cluster.
discovery: ${discovery}

# Valid values include 'exit', 'proxy'
discovery-fallback: 'exit'

# HTTP proxy to use for traffic to discovery service.
discovery-proxy:

# DNS domain used to bootstrap initial cluster.
discovery-srv: ${discovery_srv}

# Initial cluster configuration for bootstrapping.
initial-cluster:

# Initial cluster token for the etcd cluster during bootstrap.
initial-cluster-token: 'discovery-token'

# Initial cluster state ('new' or 'existing').
initial-cluster-state: 'new'

# Reject reconfiguration requests that would cause quorum loss.
strict-reconfig-check: false

# Accept etcd V2 client requests
enable-v2: false

# Enable runtime profiling data via HTTP server
enable-pprof: false

# Valid values include 'on', 'readonly', 'off'
proxy: 'off'

# Time (in milliseconds) an endpoint will be held in a failed state.
proxy-failure-wait: 5000

# Time (in milliseconds) of the endpoints refresh interval.
proxy-refresh-interval: 30000

# Time (in milliseconds) for a dial to timeout.
proxy-dial-timeout: 1000

# Time (in milliseconds) for a write to timeout.
proxy-write-timeout: 5000

# Time (in milliseconds) for a read to timeout.
proxy-read-timeout: 0

client-transport-security:
  # DEPRECATED: Path to the client server TLS CA file.
  ca-file:

  # Path to the client server TLS cert file.
  cert-file:

  # Path to the client server TLS key file.
  key-file:

  # Enable client cert authentication.
  client-cert-auth: false

  # Path to the client server TLS trusted CA key file.
  trusted-ca-file:

  # Client TLS using generated certificates
  auto-tls: ${ssl}

peer-transport-security:
  # DEPRECATED: Path to the peer server TLS CA file.
  ca-file:

  # Path to the peer server TLS cert file.
  cert-file:

  # Path to the peer server TLS key file.
  key-file:

  # Enable peer client cert authentication.
  peer-client-cert-auth: false

  # Path to the peer server TLS trusted CA key file.
  trusted-ca-file:

  # Peer TLS using generated certificates.
  auto-tls: ${ssl}

# Enable debug-level logging for etcd.
debug: false

# Specify a particular log level for each etcd package (eg: 'etcdmain=CRITICAL,etcdserver=DEBUG'.
log-package-levels:

# Specify 'stdout' or 'stderr' to skip journald logging even when running under systemd.
log-output: default

# Force to create a new one member cluster.
force-new-cluster: false
EOF

# ETCDCTL_API=3 /usr/local/bin/etcdctl member list --cert /var/lib/etcd/fixtures/client/cert.pem  --key /var/lib/etcd/fixtures/client/key.pem  --endpoints $PROTOCOL://localhost:2379 --insecure-skip-tls-verify
