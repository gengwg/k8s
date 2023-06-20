## Install

### Linux

https://krew.sigs.k8s.io/docs/user-guide/setup/install/

```
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl  $(fwdproxy-config curl) -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  https_proxy="http://fwdproxy:8080" ./"${KREW}" install krew
)
```

[Example](https://gist.github.com/gengwg/ebdea1c7cc0d230cc8f42a68afed29e7)

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

### Tree

```
$ k tree deploy alpine-deployment
NAMESPACE  NAME                                        READY  REASON  AGE
default    Deployment/alpine-deployment                -              15m
default    └─ReplicaSet/alpine-deployment-6bc7894dbc   -              15m
default      ├─Pod/alpine-deployment-6bc7894dbc-6cvbn  True           15m
default      ├─Pod/alpine-deployment-6bc7894dbc-6r4zq  True           15m
default      └─Pod/alpine-deployment-6bc7894dbc-7c6mt  True           15m
```
