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
