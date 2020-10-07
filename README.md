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

## Commands

### Watch a command using -w

```
$ kubectl get jobs -w
NAME               COMPLETIONS   DURATION   AGE
hello-1600848720   1/1           3s         18h
hello-1600848780   1/1           3s         18h
hello-1600848840   1/1           3s         18h
```

### Get services from all namespaces

```
$ kubectl get svc -A | grep graf
ingress-nginx   grafana                              NodePort       10.97.25.250     <none>        3000:30552/TCP               7d7h
```
### Get ServiceMonitor's

```
$ kubectl get servicemonitor
```

### Creates a proxy server

Creates a proxy server or application-level gateway between localhost and the Kubernetes API Server. Allow access from anywhere.

```
$ kubectl proxy --address=0.0.0.0 --accept-hosts=.*
Starting to serve on [::]:8001
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

### Helm Install Prometheus on Mac

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm search repo prometheus-community
helm install myprom prometheus-community/prometheus
# get prometheus service ports
kubectl get svc
# forward prometheus port to local port
kubectl port-forward service/myprom-prometheus-server 9090:80
# go to browser to test
curl localhost:9090/graph
```

### Debugging Pods

```
kubectl describe pods ${POD_NAME}
```

### Cronjob

Looks k8s cronjobs default uses UTC, even if the master time zone is set to PDT.

## Helm

### Install Helm

https://helm.sh/docs/intro/install/

#### Linux

```
wget https://get.helm.sh/helm-v3.3.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
tar -zvxf helm-v3.3.4-linux-amd64.tar.gz
```

#### MacOS

```
brew install helm
```

### Add Repo

```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
```

### Uninstall chart release

```
helm list   # find the release name to delete
helm uninstall <release_name>
```

### Get a local copy of chart

```
helm fetch prometheus-community/prometheus --untar
```

### Prepare a template to install on k8s

```
helm template myprom prometheus-community/prometheus > k8s-myprom.yaml
kubectl apply -f k8s-myprom.yaml
```

### Install chart into a specific namespace

```sh
$ kubectl create ns monitoring
$ helm install prometheus stable/prometheus-operator --namespace monitoring
# uninstall need namespace name specified
$ helm uninstall prometheus --namespace monitoring
release "prometheus" uninstalled
```

## Errors

### `/data` directory permission issues

```
level=error ts=2020-09-26T01:03:04.688Z caller=query_logger.go:87 component=activeQueryTracker msg="Error opening query log  file" file=/data/queries.active err="open /data/queries.active: permission denied"
panic: Unable to create mmap-ed active query log
goroutine 1 [running]:
github.com/prometheus/prometheus/promql.NewActiveQueryTracker(0x7fffcbccf6de, 0x5, 0x14, 0x30898a0, 0xc000c2cae0, 0x30898a0)
>---/app/promql/query_logger.go:117 +0x4cd
main.main()
>---/app/cmd/prometheus/main.go:374 +0x4f08
```

===>

```
      securityContext:
        fsGroup: 0
        #fsGroup: 65534
        #fsGroup: 2000
        #runAsGroup: 65534
        runAsGroup: 0
        #runAsNonRoot: true
        #runAsUser: 65534
        runAsUser: 0
```

### error with Volume binding for prometheus server

```
$ k describe pods  myprom-prometheus-server-8d4c6bcb5-9ckwj
...

Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  51s (x20 over 25m)  default-scheduler  running "VolumeBinding" filter plugin for pod "myprom-prometheus-server-8d4c6bcb5-9ckwj": pod has unbound immediate PersistentVolumeClaims
```

===> 

execute below mkdir command in all the nodes in the cluster.

```
$ sudo mkdir /mnt/prometheusvol{1,2}
```

Then execute in master server,

```
$ k get pvc
NAME                              STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
myprom-prometheus-alertmanager   Pending                                                     30m
myprom-prometheus-server         Pending                                                     30m

$ k create -f - <<EOF
> kind: PersistentVolume
> apiVersion: v1
> metadata:
>   name: prometheusvol1
> spec:
>   storageClassName:
>   capacity:
>     storage: 5Gi
>   accessModes:
>     - ReadWriteOnce
>   hostPath:
>     path: "/mnt/prometheusvol1"
> ---
> kind: PersistentVolume
> apiVersion: v1
> metadata:
>   name: prometheusvol2
> spec:
>   storageClassName:
>   capacity:
>     storage: 10Gi
>   accessModes:
>     - ReadWriteOnce
>   hostPath:
>     path: "/mnt/prometheusvol2"
> EOF
persistentvolume/prometheusvol1 created
persistentvolume/prometheusvol2 created

$ k get pvc
NAME                              STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   AGE
myprom-prometheus-alertmanager   Bound    prometheusvol1   5Gi        RWO                           35m
myprom-prometheus-server         Bound    prometheusvol2   10Gi       RWO                           35m
```
