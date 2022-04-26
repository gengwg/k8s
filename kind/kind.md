# KIND

Kind is a tool for running local Kubernetes clusters using Docker container “nodes”.

## Install

```
# on Mac
brew install kind

# on Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
chmod +x ./kind
mv ./kind ~/bin/kind

$ kind create cluster
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.17.0) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅 Check out https://kind.sigs.k8s.io/docs/user/quick-start/

gengwg@gengwg-mbp:~/$ docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED              STATUS              PORTS                       NAMES
44bbd3ff16fe        kindest/node:v1.17.0   "/usr/local/bin/entr…"   About a minute ago   Up About a minute   127.0.0.1:32768->6443/tcp   kind-control-plane

$ kubectl cluster-info --context kind-kind
Kubernetes master is running at https://127.0.0.1:32768
KubeDNS is running at https://127.0.0.1:32768/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

$ kubectl get nodes
NAME                 STATUS     ROLES    AGE   VERSION
kind-control-plane   NotReady   master   48s   v1.19.1
```

## Commands

### Delete clusters:

```
$ kind get clusters
kind
my-cluster
$ kind delete clusters my-cluster
Deleted clusters: ["my-cluster"]
$ kind get clusters
kind
```

### Create multi-node cluster:

```
kind create cluster --config kind-multi-node.yaml --name kind-multi-node

$ kubectl get no
NAME                            STATUS     ROLES    AGE   VERSION
kind-multi-node-control-plane   NotReady   master   51s   v1.19.1
kind-multi-node-worker          NotReady   <none>   16s   v1.19.1
kind-multi-node-worker2         NotReady   <none>   16s   v1.19.1

# delete
$ kind delete cluster --name kind-multi-node
```

### Update kind binary:

```
$ cd bin
$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
```

### Load docker image into kind cluster

(useful for kind k8s cluster could not reach company internal registry).

```
kind load docker-image <my-image>
```

### Create a new cluster with different name:

```
$ kind create cluster --name my-cluster
```

### Create a cluster using yaml config:

```
$ kind create cluster --name cluster2 --config kind.yaml
```

### Create a cluster with specific k8s version

```
$ kind create cluster --image kindest/node:v1.22.9
``` 
