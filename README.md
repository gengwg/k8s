# k8s

The worker node(s) host the Pods that are the components of the application workload. The control plane manages the worker nodes and the Pods in the cluster.

![](https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg)

The container runtime is the software that is responsible for running containers.

Kubernetes run times

Cluster DNS is a DNS server, in addition to the other DNS server(s) in your environment, which serves DNS records for Kubernetes services. Containers started by Kubernetes automatically include this DNS server in their DNS searches.

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

Delete cluster:

```
kind delete cluster
```

Load docker image:
(useful for kind k8s cluster could not reach company internal registry).

```
kind load docker-image <my-image>
```

Create a new cluster with different name:

```
$ kind create cluster --name my-cluster
```


Create a cluster using yaml config:

```
$ kind create cluster --name cluster2 --config kind.yaml 
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

## Minikube

```
brew install minikube
minikube version
$ minikube start # first time takes long time
😄  minikube v1.19.0 on Darwin 11.2.3
✨  Automatically selected the docker driver. Other choices: hyperkit, virtualbox, ssh
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.20.2 preload ...
    > gcr.io/k8s-minikube/kicbase...: 237.57 MiB / 357.67 MiB  66.42% 4.55 MiB
    > preloaded-images-k8s-v10-v1...: 385.37 MiB / 491.71 MiB  78.37% 7.40 MiB
    > index.docker.io/kicbase/sta...: 357.67 MiB / 357.67 MiB  100.00% 4.57 MiB
❗  minikube was unable to download gcr.io/k8s-minikube/kicbase:v0.0.20, but successfully downloaded kicbase/stable:v0.0.20 as a fallback image
🔥  Creating docker container (CPUs=2, Memory=1988MB) ...
    > kubectl.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubelet.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm: 37.40 MiB / 37.40 MiB [------------] 100.00% 6.04 MiB p/s 6.394s
    > kubectl: 38.37 MiB / 38.37 MiB [------------] 100.00% 4.46 MiB p/s 8.798s
    > kubelet: 108.73 MiB / 108.73 MiB [---------] 100.00% 7.15 MiB p/s 15.403s

    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
❗  Executing "docker container inspect minikube --format={{.State.Status}}" took an unusually long time: 3.05293417s
💡  Restarting the docker service may improve performance.
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

### List Addons

```
minikube addons list
```

### Enable Addons

```
minikube addons enable dashboard
```

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

## Commands

### Mac Install a few k8s Tools

```
brew install kubectl
brew install kubectx
brew install octant
brew install kustomize
```

Usage:

```
$ kubens
default <-- highlighted
flux-system
kube-node-lease
kube-public
kube-system
local-path-storage
monitoring
$ kubens monitoring
Context "kind-kind" modified.
Active namespace is "monitoring".
$ kubens
default
flux-system
kube-node-lease
kube-public
kube-system
local-path-storage
monitoring <-- highlighted
$ k get pods
<now will show pods in monitoring namespace>
```

### kubectl switch k8s context

The context in Kubernetes is like a connection to a server that tells Kubernetes which Cluster to connect to.

When we set the context, Kubernetes will send all the command to the cluster that is set in the context.

```
$ kubectl config get-contexts
CURRENT   NAME              CLUSTER           AUTHINFO          NAMESPACE
*         kind-cluster2     kind-cluster2     kind-cluster2     
          kind-kind         kind-kind         kind-kind         
          kind-my-cluster   kind-my-cluster   kind-my-cluster   
$ kubectl config current-context
kind-cluster2
$ kubectl config use-context kind-kind
Switched to context "kind-kind".
$ kubectl config current-context
kind-kind
$ kubectl config get-contexts
CURRENT   NAME              CLUSTER           AUTHINFO          NAMESPACE
          kind-cluster2     kind-cluster2     kind-cluster2     
*         kind-kind         kind-kind         kind-kind         
          kind-my-cluster   kind-my-cluster   kind-my-cluster   
```

### Get kubernetes version

```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.2", GitCommit:"f5743093fd1c663cb0cbc89748f730662345d44d", GitTreeState:"clean", BuildDate:"2020-09-16T13:41:02Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.1", GitCommit:"206bcadf021e76c27513500ca24182692aabd17e", GitTreeState:"clean", BuildDate:"2020-09-14T07:30:52Z", GoVersion:"go1.15", Compiler:"gc", Platform:"linux/amd64"}
```

Shorter version:

```
$ kubectl version --short=true
Client Version: v1.20.0
Server Version: v1.19.1
```

Only check client version and omit server version:

```
$ kubectl version --short=true --client=true
Client Version: v1.20.0
```


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

### Create a New Namespace

```
$ kubectl create namespace gengwg
```

### Get a specific service

```
$ kubectl get service redis-master
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
redis-master   ClusterIP   10.96.104.226   <none>        6379/TCP   6s
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

### Get pods using label

```sh
$ kubectl --namespace monitoring get pods -l "release=prometheus"
NAME                                                   READY   STATUS    RESTARTS   AGE
prometheus-prometheus-node-exporter-dbkhl              0/1     Pending   0          68s
prometheus-prometheus-oper-operator-85cc758cdb-6c5pc   2/2     Running   0          68s
```

### Force delete pods

```
kubectl delete pods pod_name --grace-period=0 --force -n myns
```

Be careful using this though. If you need force delete a pod, there is usually an issue with the cluster itself going on. So check cluster status before doing that.

### Debugging Pods

```
kubectl describe pods ${POD_NAME}
```

### Use Port Forwarding to Access Applications in a Cluster

```
kubectl port-forward redis-master-765d459796-258hz 7000:6379
kubectl port-forward pods/redis-master-765d459796-258hz 7000:6379
kubectl port-forward deployment/redis-master 7000:6379
kubectl port-forward replicaset/redis-master 7000:6379
kubectl port-forward service/redis-master 7000:6379
```

Connections made to local port 7000 are forwarded to port 6379 of the Pod that is running the Redis server.

```
$ redis-cli -p 7000
127.0.0.1:7000> ping
PONG
```

### Get all resources in a namespace

```
kubectl get all -n monitoring
```

### Create Configmap

```
$ kubectl create configmap logger --from-literal=log_level=debug
$ k get cm/logger -o yaml
apiVersion: v1
data:
  log_level: debug
kind: ConfigMap
metadata:
  creationTimestamp: "2021-04-17T16:40:11Z"
  name: logger
  namespace: default
  resourceVersion: "37730"
  uid: 67ac0419-d2f7-41b1-be90-47d083ffb629
$ k get cm
NAME               DATA   AGE
kube-root-ca.crt   1      24h
logger             1      3m15s
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

### Create Secret

```
$ kubectl create secret generic apikey --from-literal=api_key=1234567
secret/apikey created
```

### Copy kubernetes secret from one namespace to another

```
kubectl get secret mysecret --namespace=namespace1 -o yaml | sed 's/namespace: namespace1/namespace: namespace2/g' | kubectl create -f -  
```

### List the taints on Kubernetes nodes

```
kubectl get nodes -o json | jq '.items[].spec.taints'
```

### List all Container images in all namespaces

```
kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq -c
```

### Getting a shell to a pod/container

Get interactive shell to a Pod (if the Pod has multiple containers, you will login to a default one, i.e. the first container specified in the Pod’s config.):

```
kubectl exec --stdin --tty <pod name> -- /bin/sh
```

Login to a particular container in the Pod:

```
# first get the containers in the pod:
$ k get pods <pod name> -o jsonpath='{.spec.containers[*].name}'
container1 container2

# log in to a particular pod:
$ k exec --stdin --tty <pod name> -c container1 -- /bin/sh
/ $
$ k exec --stdin --tty <pod name> -c container2 -- /bin/sh
~ $
```


### Checking running config for pod/config map/daemon set:

```
$ kubectl get pod calico-node-8l84t -n kube-system -o yaml
$ kubectl get ConfigMap calico-config -n kube-system -o yaml
$ kubectl get DaemonSet calico-node -n kube-system -o yaml > calico-daemonset.yaml
```

### View k8s resources and shortnames

```
$ kubectl api-resources
NAME                              SHORTNAMES   APIVERSION                               NAMESPACED   KIND
bindings                                       v1                                       true         Binding
componentstatuses                 cs           v1                                       false        ComponentStatus
configmaps                        cm           v1                                       true         ConfigMap
endpoints                         ep           v1                                       true         Endpoints
events                            ev           v1                                       true         Event
limitranges                       limits       v1                                       true         LimitRange
namespaces                        ns           v1                                       false        Namespace
nodes                             no           v1                                       false        Node
persistentvolumeclaims            pvc          v1                                       true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                       false        PersistentVolume
pods                              po           v1                                       true         Pod
podtemplates                                   v1                                       true         PodTemplate
replicationcontrollers            rc           v1                                       true         ReplicationController
resourcequotas                    quota        v1                                       true         ResourceQuota
secrets                                        v1                                       true         Secret
serviceaccounts                   sa           v1                                       true         ServiceAccount
services                          svc          v1                                       true         Service
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1          false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1          false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1                  false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io/v1                false        APIService
controllerrevisions                            apps/v1                                  true         ControllerRevision
daemonsets                        ds           apps/v1                                  true         DaemonSet
deployments                       deploy       apps/v1                                  true         Deployment
replicasets                       rs           apps/v1                                  true         ReplicaSet
statefulsets                      sts          apps/v1                                  true         StatefulSet
tokenreviews                                   authentication.k8s.io/v1                 false        TokenReview
localsubjectaccessreviews                      authorization.k8s.io/v1                  true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                  false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                  false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                  false        SubjectAccessReview
horizontalpodautoscalers          hpa          autoscaling/v1                           true         HorizontalPodAutoscaler
cronjobs                          cj           batch/v1beta1                            true         CronJob
jobs                                           batch/v1                                 true         Job
certificatesigningrequests        csr          certificates.k8s.io/v1                   false        CertificateSigningRequest
leases                                         coordination.k8s.io/v1                   true         Lease
endpointslices                                 discovery.k8s.io/v1beta1                 true         EndpointSlice
events                            ev           events.k8s.io/v1                         true         Event
ingresses                         ing          extensions/v1beta1                       true         Ingress
helmreleases                      hr           helm.toolkit.fluxcd.io/v2beta1           true         HelmRelease
kustomizations                    ks           kustomize.toolkit.fluxcd.io/v1beta1      true         Kustomization
ingressclasses                                 networking.k8s.io/v1                     false        IngressClass
ingresses                         ing          networking.k8s.io/v1                     true         Ingress
networkpolicies                   netpol       networking.k8s.io/v1                     true         NetworkPolicy
runtimeclasses                                 node.k8s.io/v1beta1                      false        RuntimeClass
alerts                                         notification.toolkit.fluxcd.io/v1beta1   true         Alert
providers                                      notification.toolkit.fluxcd.io/v1beta1   true         Provider
receivers                                      notification.toolkit.fluxcd.io/v1beta1   true         Receiver
poddisruptionbudgets              pdb          policy/v1beta1                           true         PodDisruptionBudget
podsecuritypolicies               psp          policy/v1beta1                           false        PodSecurityPolicy
clusterrolebindings                            rbac.authorization.k8s.io/v1             false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1             false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io/v1             true         RoleBinding
roles                                          rbac.authorization.k8s.io/v1             true         Role
priorityclasses                   pc           scheduling.k8s.io/v1                     false        PriorityClass
buckets                                        source.toolkit.fluxcd.io/v1beta1         true         Bucket
gitrepositories                                source.toolkit.fluxcd.io/v1beta1         true         GitRepository
helmcharts                                     source.toolkit.fluxcd.io/v1beta1         true         HelmChart
helmrepositories                               source.toolkit.fluxcd.io/v1beta1         true         HelmRepository
csidrivers                                     storage.k8s.io/v1                        false        CSIDriver
csinodes                                       storage.k8s.io/v1                        false        CSINode
storageclasses                    sc           storage.k8s.io/v1                        false        StorageClass
volumeattachments                              storage.k8s.io/v1                        false        VolumeAttachment
```

### Get more detailed outputs using -owide option

```
$ kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
alpine                     1/1     Running   109        7d19h
podinfo-7466f7f75b-lfb2p   1/1     Running   0          7d19h
podinfo-7466f7f75b-wdj62   1/1     Running   0          7d15h
$ kubectl get pods -owide
NAME                       READY   STATUS    RESTARTS   AGE     IP            NODE                 NOMINATED NODE   READINESS GATES
alpine                     1/1     Running   109        7d19h   10.244.0.9    kind-control-plane   <none>           <none>
podinfo-7466f7f75b-lfb2p   1/1     Running   0          7d19h   10.244.0.12   kind-control-plane   <none>           <none>
podinfo-7466f7f75b-wdj62   1/1     Running   0          7d15h   10.244.0.13   kind-control-plane   <none>           <none>
```

### Show pods labels

```
$ kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE    LABELS
helloworld                    1/1     Running   0          27s    application_type=ui,author=karthequian,env=production,release-version=1.0
```
### Modify labels to a running pod

```
$ kubectl label po/helloworld app=helloworldapp --overwrite
pod/helloworld labeled
$ kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE    LABELS
helloworld                    1/1     Running   0          4m3s   app=helloworldapp,application_type=ui,author=karthequian,env=production,release-version=1.0
```

Label a node:

```
$ k label node/minikube infra=development --overwrite
```

### Delete label from a pod
```
$ kubectl label po/helloworld app-
pod/helloworld labeled
$ kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE     LABELS
helloworld                    1/1     Running   0          5m57s   application_type=ui,author=karthequian,env=production,release-version=1.0
```

### Select with labels

```
$ k get pods --selector env=production
$ k get pods --selector dev-lead=karthik,env=staging
NAME               READY   STATUS    RESTARTS   AGE
homepage-staging   1/1     Running   0          3m26s
$ k get pods --selector dev-lead!=karthik,env=staging
$ k get pods -l 'release-version in (1.0,2.0)' --show-labels
# equivalent to above
$ k get pods --selector 'release-version in (1.0,2.0)'
$ k get pods -l 'release-version notin (1.0,2.0)' --show-labels
# delete pods using labels
$ k delete pods -l dev-lead=karthik
```

Can also be used with deployment, service, etc. labels.

### Get node a pod is running on

```
k describe podname | grep Node:
```

### kubectl verbose output

```
kubectl -v8 
```

for example

```
k -v8 port-forward svc/myservice 3000:80
```

## Notes

### Network

Kubernetes requires that each container in a cluster has a unique, routable IP. Kubernetes doesn’t assign IPs itself, leaving the task to third-party solutions.

### Cronjob

Looks k8s cronjobs default uses UTC, even if the master time zone is set to PDT.

#### Suspend a cronjob

```
$ kubectl edit cronjobs/hellocron
...
  schedule: '*/1 * * * *'
  successfulJobsHistoryLimit: 3
  suspend: true <----
...

$ k get cronjob
NAME        SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hellocron   */1 * * * *   True      0        68s             2m22s
```

#### View logs for cron job

> A `Cron Job` creates Jobs on a time-based schedule

> A `job` creates one or more pods and ensures that a specified number of them successfully terminate.

All you need is to view logs for a pod that was created for the job.

1. Find your job with `kubectl get jobs`. This will return your CronJob name with a timestamp

2. Find pod for executed job `kubectl get pods -l job-name=your-job-@timestamp`

3. Use `kubectl logs your-job-@timestamp-id` to view logs

Here's an example of bash script that does all the above and outputs logs for every job's pod.

```
jobs=( $(kubectl get jobs --no-headers -o custom-columns=":metadata.name") )
for job in "${jobs[@]}"
do
   pod=$(kubectl get pods -l job-name=$job --no-headers -o custom-columns=":metadata.name")
   kubectl logs $pod
done
```

### Sepcifying your own Cluster IP address

Cluster IP is a virtual IP that is allocated by the K8s to a service. It is K8s internal IP.
A Cluster IP makes it accessible from any of the Kubernetes cluster’s nodes.

You can specify your own cluster IP address as part of a Service creation request. To do this, set the .spec.clusterIP field.
The IP address that you choose must be a valid IPv4 or IPv6 address from within the service-cluster-ip-range CIDR range that is configured for the API server.

Example:

```
# abc-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - name: "myservice"
      protocol: TCP
      port: 8080
      targetPort: 8080
  clusterIP: 10.96.104.222
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

### error upgrading connection: unable to upgrade connection: Forbidden

```
$ k port-forward svc/prometheus 9090:9090 -n monitoring
error: error upgrading connection: unable to upgrade connection: Forbidden (user=kubernetes, verb=create, resource=nodes, subresource=proxy)
```

Kubectl exec has same error.

Checked auth no problem:

```
$ k auth can-i create nodes/proxy -n monitoring
Warning: resource 'nodes' is not namespace scoped
yes
```

This is general, not only to some specific service. e.gl dex also having issue:

```
# KUBECONFIG=admin.kubeconfig kubectl port-forward svc/dex 5556:5556 -n auth
error: error upgrading connection: unable to upgrade connection: Forbidden (user=kubernetes, verb=create, resource=nodes, subresource=proxy)
```

===>

Root cause: 使用 kubectl exec 命令时，会转到kubelet，需要对 apiserver 调用 kubelet API 的授权。所以跟 kubectl 的其他命令有些区别。

```
$ k create clusterrolebinding system:kubernetes --clusterrole=cluster-admin --user=system:kubernetes
clusterrolebinding.rbac.authorization.k8s.io/system:kubernetes created
$ KUBECONFIG=admin.kubeconfig kubectl port-forward  svc/dex 5556:5556 -n auth
error: error upgrading connection: unable to upgrade connection: Forbidden (user=kubernetes, verb=create, resource=nodes, subresource=proxy)
```

```
$ k create clusterrolebinding kubernetes --clusterrole=cluster-admin --user=kubernetes
clusterrolebinding.rbac.authorization.k8s.io/kubernetes created
$ KUBECONFIG=admin.kubeconfig kubectl port-forward  svc/dex 5556:5556 -n auth
Forwarding from 127.0.0.1:5556 -> 5556
Forwarding from [::1]:5556 -> 5556
```

Idea came from: https://blog.csdn.net/doyzfly/article/details/102963001

解决办法1:
为 kubectl 创建一个用于鉴权的用户信息，并存在 kubeconfig 中，然后使用 RoleBinding 绑定用户权限，这个方法比较复杂，可参考这边文章配置，创建用户认证授权的kubeconfig文件

解决办法2:
为 system:anonymous 临时绑定一个 cluster-admin 的权限

kubectl create clusterrolebinding system:anonymous --clusterrole=cluster-admin --user=system:anonymous

这个权限放太松了，很危险。 可以只对 anonymous 用户绑定必要权限即可，修改为：

kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user=system:anonymous

## Resources

- https://github.com/kelseyhightower/kubernetes-the-hard-way
