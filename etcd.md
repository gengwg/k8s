### Basic Usage

ETCDCTL can interact with ETCD Server using 2 API versions - Version 2 and Version 3.  By default its set to use Version 2. Each version has different sets of commands.

To set the right version of API set the environment variable ETCDCTL_API command

```
export ETCDCTL_API=3
```

Apart from that, you must also specify path to certificate files so that ETCDCTL can authenticate to the ETCD API Server. The certificate files are available in the etcd-master at the following path.

```
    --cacert /etc/kubernetes/pki/etcd/ca.crt
    --cert /etc/kubernetes/pki/etcd/server.crt
    --key /etc/kubernetes/pki/etcd/server.key
```

Equivalently one may use env variables:

```
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
```

You can find these certificate files on the cp node:

```
<cp host> $ ll /etc/kubernetes/pki/etcd/
total 32
-rw-r--r-- 1 root root 1058 Sep 22  2020 ca.crt
-rw------- 1 root root 1675 Sep 22  2020 ca.key
-rw-r--r-- 1 root root 1139 Sep 22  2020 healthcheck-client.crt
-rw------- 1 root root 1679 Sep 22  2020 healthcheck-client.key
-rw-r--r-- 1 root root 1172 Sep 22  2020 peer.crt
-rw------- 1 root root 1679 Sep 22  2020 peer.key
-rw-r--r-- 1 root root 1172 Sep 22  2020 server.crt
-rw------- 1 root root 1675 Sep 22  2020 server.key
```

### List members of the etcd cluster

```
$ kubectl -n kube-system exec -it etcd-kind-control-plane  -- sh -c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl member list
"
5320353a7d98bdee, started, kind-control-plane, https://172.18.0.4:2380, https://172.18.0.2:2379, false
```

Or use non env variable way:

```
$ kubectl -n kube-system exec -it etcd-kind-control-plane  -- sh -c "ETCDCTL_API=3 etcdctl --cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key \
member list
"
5320353a7d98bdee, started, kind-control-plane, https://172.18.0.4:2380, https://172.18.0.2:2379, false
```

### To change the leader in the etcd cluster

First get the id of the node you want to be the leader, using:

```
etcdctl -w table endpoint status
```

or 

```
etcdctl -w table member list
```

To change the leader in the etcd cluster:

```
etcdctl move-leader <id-of-the-node-you-want-to-be-the-leader>
```

### List all keys stored by K8s

```
$ kubectl -n kube-system exec -it etcd-kind-control-plane  -- sh -c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl get / --prefix --keys-only
"
```

Or not using env variable:

```
$ kubectl -n kube-system exec -it etcd-kind-control-plane  -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=5 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key"
/registry/apiregistration.k8s.io/apiservices/v1.

/registry/apiregistration.k8s.io/apiservices/v1.admissionregistration.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.apiextensions.k8s.io

/registry/apiregistration.k8s.io/apiservices/v1.apps

/registry/apiregistration.k8s.io/apiservices/v1.authentication.k8s.io
```

### Write a new key

```
$ sudo ETCDCTL_API=3 etcdctl --cert=/etc/pki/tls/certs/cp1.example.com.pem --cacert=/etc/pki/ca-trust/extracted/pem/ca-bundle.pem --key=/etc/pki/tls/private/cp1.example.com.pem.key --endpoints=$ENDPOINTS put newkey 123
```

### Delete one key

```
$ sudo ETCDCTL_API=3 etcdctl --cert=/etc/pki/tls/certs/cp1.example.com.pem --cacert=/etc/pki/ca-trust/extracted/pem/ca-bundle.pem --key=/etc/pki/tls/private/cp1.example.com.pem.key --endpoints=$ENDPOINTS del /registry/cert-manager.io/certificaterequests/xyz-system/xyz-webhook-server-cert-22jzr
```

### Delete all keys under a namespace

```
$ sudo ETCDCTL_API=3 etcdctl --cert=/etc/pki/tls/certs/cp1.example.com.pem --cacert=/etc/pki/ca-trust/extracted/pem/ca-bundle.pem --key=/etc/pki/tls/private/cp1.example.com.pem.key --endpoints=$ENDPOINTS del /registry/cert-manager.io/certificaterequests/xyz-system/ --prefix
```

### Snapshot backup 

etcd leader is guaranteed to have the latest application data, thus fetch snapshot from leader:

```
# etcdctl --endpoints=https://<leader node>:2379 snapshot save backup.db
```

## Maintenance

### Reprovision a node

This is similar to Add new nodes to the cluster. The reprovisioned node gets a new id.


Find the old id for the reprovisioned node.

```
ETCD_KEY_FILE="/var/lib/kubernetes/etcd.key"
ETCD_CERT_FILE="/var/lib/kubernetes/etcd.pem"
ETCD_TRUSTED_CA_FILE="/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem"
ETCDRUN_ENDPOINTS="https://cp01.example.com:2379,https://cp02.example.com:2379,https://cp03.example.com:2379"

sudo ETCDCTL_API=3 etcdctl --cert=$ETCD_CERT_FILE --cacert=$ETCD_TRUSTED_CA_FILE --key=$ETCD_KEY_FILE  --endpoints=$ETCDRUN_ENDPOINTS --write-out=table member list
```

Delete old ID:

```
sudo ETCDCTL_API=3 etcdctl --cert=$ETCD_CERT_FILE --cacert=$ETCD_TRUSTED_CA_FILE --key=$ETCD_KEY_FILE  --endpoints=$ETCDRUN_ENDPOINTS --write-out=table  member remove <oldMemberID>
```

Readd it with new member ID:

```
sudo ETCDCTL_API=3 etcdctl --cert=$ETCD_CERT_FILE --cacert=$ETCD_TRUSTED_CA_FILE --key=$ETCD_KEY_FILE  --endpoints=$ETCDRUN_ENDPOINTS member add node01.example.com --peer-urls=https://node01.example.com:2380
Member c41aee9cc27c6b18 added to cluster c3c2b7a6a9f4b1f1
```

Next modify ETCD_INITIAL_CLUSTER_STATE to 'existing' instead of new.

```
# vim /etc/etcd/etcd.conf

#ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_STATE="existing"

# systemctl restart etcd
```

Otherwise you will get error. This is due to previous run was saying 'new', thus generated new cluster id. 

```
2022-12-22 14:05:58.953247 E | rafthttp: request sent was ignored (cluster ID mismatch: peer[1a99766b50315703]=c3c2b7a6a9f4b1f1, local=a0ffb967612c7688)
2022-12-22 14:05:59.004285 E | rafthttp: request cluster ID mismatch (got c3c2b7a6a9f4b1f1 want a0ffb967612c7688)
```

May also Need remove previous data dir, if you previously already started etcd on it using 'new'. Otherwise it still gets the old cluste id.

```
# mv /var/lib/etcd/default.etcd/ /tmp/
# systemctl restart etcd
# tail -f  /var/log/etcd/etcd.log
```

Verify it worked:

```
sudo ETCDCTL_API=3 etcdctl --cert=$ETCD_CERT_FILE --cacert=$ETCD_TRUSTED_CA_FILE --key=$ETCD_KEY_FILE  --endpoints=$ETCDRUN_ENDPOINTS endpoint status
```

Kubectl should work now too.

```
# kubectl version --short --kubeconfig=/opt/kubernetes/kubeconfig/admin.kubeconfig
Client Version: v1.22.9
Server Version: v1.22.9
```

