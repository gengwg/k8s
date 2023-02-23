#!/usr/bin/env bash

# Wrapper for etcdctl/etcd v3 query.
# Usage Example:
# ./etcdctl-wrapper.sh endpoint status --cluster
# ./etcdctl-wrapper.sh -w members list

# Tested version
# # export ETCDCTL_API=3
# # etcdctl version
#   etcdctl version: 3.3.11
#   API version: 3.3

ETCD_CERT_FILE="/var/lib/kubernetes/etcd.pem"
ETCD_KEY_FILE="/var/lib/kubernetes/etcd.key"
ETCD_TRUSTED_CA_FILE="/etc/pki/ca-trust/tls-ca-bundle.pem"
# List all endpoints
ETCDRUN_ENDPOINTS="https://kubectrlplane101.example.com:2379,https://kubectrlplane102.example.com:2379,https://kubectrlplane103.example.com:2379"
sudo ETCDCTL_API=3 etcdctl --cert=$ETCD_CERT_FILE --cacert=$ETCD_TRUSTED_CA_FILE --key=$ETCD_KEY_FILE  --endpoints=$ETCDRUN_ENDPOINTS $*
