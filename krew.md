## Install

### Linux

https://krew.sigs.k8s.io/docs/user-guide/setup/install/

### Mac

```
brew install krew
kubectl krew update
kubectl krew install access-matrix
```

## Plugins

```
kubectl krew install access-matrix
kubectl krew install auth-proxy
kubectl krew install blame
kubectl krew install ca-cert
kubectl krew install cert-manager
kubectl krew install confirm
kubectl krew install cost
kubectl krew install custom-cols
deprecations
kubectl krew install ingress-enginx
kubectl krew install kyverno
minio
neat
kubectl krew install oidc-login
rbac-lookup
rbac-tool
resource-capacity
sniff
skew
slice
starboard
tail
kubectl krew install tree
who-can
whoami
```

Note: If you are operating within a proxy environment, you must prepend the proxy before executing the commands. For example:

```
https_proxy="http://fwdproxy:8080" kubectl krew install tree
```

## Examples

### Check Deprecated/Deleted APIs

```
$ https_proxy="http://fwdproxy:8080" k deprecations --k8s-version=v1.26.0
```

[example](https://gist.github.com/gengwg/2abcf404109d218fb2fd908e9f526c0a)
