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

### Deploy Prometheus Server and Grafana

#### Prometheus

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.35.0/deploy/static/provider/cloud/deploy.yaml
$ kubectl apply --kustomize github.com/kubernetes/ingress-nginx/deploy/prometheus/
$ kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.99.49.219     <pending>     80:31951/TCP,443:31670/TCP   8m36s
ingress-nginx-controller-admission   ClusterIP      10.104.101.132   <none>        443/TCP                      8m36s
prometheus-server                    NodePort       10.103.255.197   <none>        9090:31915/TCP               4m29s
$ kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}
172.18.0.2
```

Then in browser go to:

http://172.18.0.2:31915/graph

#### Grafana

```
$ kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
grafana                              NodePort       10.97.25.250     <none>        3000:30552/TCP               2m44s
ingress-nginx-controller             LoadBalancer   10.99.49.219     <pending>     80:31951/TCP,443:31670/TCP   14m
ingress-nginx-controller-admission   ClusterIP      10.104.101.132   <none>        443/TCP                      14m
prometheus-server                    NodePort       10.103.255.197   <none>        9090:31915/TCP               10m
```

Then in browser go to:

http://172.18.0.2:30552

The username and password is admin

### Debugging Pods

```
kubectl describe pods ${POD_NAME}
```

