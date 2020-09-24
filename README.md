# k8s

Kubernetes run times

* Docker
* Containerd
* CRIO

## KIND

Kind is a tool for running local Kubernetes clusters using Docker container “nodes”.

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

gengwg@gengwg-mbp:~/fb$ docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED              STATUS              PORTS                       NAMES
44bbd3ff16fe        kindest/node:v1.17.0   "/usr/local/bin/entr…"   About a minute ago   Up About a minute   127.0.0.1:32768->6443/tcp   kind-control-plane

$ kubectl cluster-info --context kind-kind
Kubernetes master is running at https://127.0.0.1:32768
KubeDNS is running at https://127.0.0.1:32768/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

$ kubectl get nodes
NAME                 STATUS     ROLES    AGE   VERSION
kind-control-plane   NotReady   master   48s   v1.19.1
$ kubectl get nodes
NAME                 STATUS   ROLES    AGE   VERSION
kind-control-plane   Ready    master   62s   v1.19.1
```


### Alpline hello world example

```
$ kubectl apply -f alpine2.yml
pod/alpine created
$ kubectl get pods
NAME     READY   STATUS    RESTARTS   AGE
alpine   1/1     Running   0          6s
$ kubectl delete -f alpine2.yml
pod "alpine" deleted
$ kubectl get pods
No resources found.
```

## Usage

### Watch a command using -w

```
$ kubectl get jobs -w
NAME               COMPLETIONS   DURATION   AGE
hello-1600848720   1/1           3s         18h
hello-1600848780   1/1           3s         18h
hello-1600848840   1/1           3s         18h
```
