Delete clusters:

```
$ kind get clusters
kind
my-cluster
$ kind delete clusters my-cluster
Deleted clusters: ["my-cluster"]
$ kind get clusters
kind
```

Create multi-node cluster:

```
kind create cluster --config kind-multi-node.yaml --name kind-multi-node

$ kubectl get no
NAME                            STATUS     ROLES    AGE   VERSION
kind-multi-node-control-plane   NotReady   master   51s   v1.19.1
kind-multi-node-worker          NotReady   <none>   16s   v1.19.1
kind-multi-node-worker2         NotReady   <none>   16s   v1.19.1
```

Update kind binary:

```
$ cd bin
$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
```
