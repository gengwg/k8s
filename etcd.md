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
