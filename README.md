# k8s

The worker node(s) host the Pods that are the components of the application workload. The control plane manages the worker nodes and the Pods in the cluster.

![](https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg)

The container runtime is the software that is responsible for running containers.

Kubernetes run times

Cluster DNS is a DNS server, in addition to the other DNS server(s) in your environment, which serves DNS records for Kubernetes services. Containers started by Kubernetes automatically include this DNS server in their DNS searches.

* Docker
* Containerd
* CRIO

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

### Start Minikube with a specific Kubernetes version

```
$ minikube start --kubernetes-version=v1.21.5
```

### List Addons

```
minikube addons list
```

### Enable Addons

```
minikube addons enable dashboard
```

## Commands

### Mac Install a few k8s Tools

```
brew install kubectl
brew install kubectx
brew install octant
brew install kustomize
brew install helm

brew install kind
brew install minikube

# k8s operator tools
brew install kubebuilder
brew install tilt

# krew
brew install krew
kubectl krew update
kubectl krew install access-matrix
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

A kubernetes context is just a set of access parameters that contains a Kubernetes cluster, a user, and a namespace. kubernetes Context is essentially the configuration that you use to access a particular cluster & namespace with a user account.

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

Get contexts names only:

```
k config get-contexts -o name

k config view -o jsonpath="{.contexts[*].name}"

# without kubectl
$ cat ~/.kube/config | grep current | sed -e "s/current-context: //"
kind-kind-multi-node
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

### Kube-proxy

Start a kube proxy server which will act as a reverse proxy for the client.

```
kubectl proxy --port <PORT_NUMBER> &
curl -s http://localhost:<PORT_NUMBER>/
curl -s http://localhost:<PORT_NUMBER>/api/v1/nodes | jq '.items[].metadata.labels'
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

### Delete multiple pods

```
$ k delete po nginx{1..3}
pod "nginx1" deleted
pod "nginx2" deleted
pod "nginx3" deleted
```

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
kubectl create secret generic apikey --from-literal=api_key=1234567

# Create a new Secret in Namespace secret called secret2 which should contain user=user1 and pass=1234
k -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234

# check it
$ k describe secrets -n secret secret2
Name:         secret2
Namespace:    secret
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
pass:  4 bytes
user:  5 bytes
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

Or use:

```
  $ kubectl api-resources -o wide
```

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

### view all API versions supported on the server, in the form of “group/version”

```
$ k api-versions
admissionregistration.k8s.io/v1
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1
apiregistration.k8s.io/v1beta1
apps/v1
authentication.k8s.io/v1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1
authorization.k8s.io/v1beta1
autoscaling/v1
autoscaling/v2beta1
autoscaling/v2beta2
batch/v1
batch/v1beta1
certificates.k8s.io/v1
certificates.k8s.io/v1beta1
coordination.k8s.io/v1
coordination.k8s.io/v1beta1
discovery.k8s.io/v1
discovery.k8s.io/v1beta1
events.k8s.io/v1
events.k8s.io/v1beta1
extensions/v1beta1
flowcontrol.apiserver.k8s.io/v1beta1
metrics.k8s.io/v1beta1
networking.k8s.io/v1
networking.k8s.io/v1beta1
node.k8s.io/v1
node.k8s.io/v1beta1
policy/v1
policy/v1beta1
rbac.authorization.k8s.io/v1
rbac.authorization.k8s.io/v1beta1
scheduling.k8s.io/v1
scheduling.k8s.io/v1beta1
storage.k8s.io/v1
storage.k8s.io/v1beta1
v1
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

$ k describe node kind-multi-node-control-plane  | grep Labels -A 10
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=kind-multi-node-control-plane
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node-role.kubernetes.io/master=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///run/containerd/containerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
```

### Modify labels to a running pod

```
$ kubectl label po/helloworld app=helloworldapp --overwrite
pod/helloworld labeled
$ kubectl get pods --show-labels
NAME                          READY   STATUS    RESTARTS   AGE    LABELS
helloworld                    1/1     Running   0          4m3s   app=helloworldapp,application_type=ui,author=karthequian,env=production,release-version=1.0
```

### Add new labels to a running pod

Add a new label tier=web to all pods having 'app=v2' or 'app=v1' label

```
$ k label po  tier=web -l app
pod/nginx1 labeled
pod/nginx2 labeled
pod/nginx3 labeled

$ k get po --show-labels
NAME     READY   STATUS    RESTARTS   AGE     LABELS
nginx1   1/1     Running   0          8m22s   app=v1,tier=web
nginx2   1/1     Running   0          7m53s   app=v2,tier=web
nginx3   1/1     Running   0          7m31s   app=v1,tier=web

k label po  tier=web -l "app in (v1,v2)"
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

### Create a pod with label

```
$ k run nginx1 --image=nginx -l=app=v1
pod/nginx1 created
$ k run nginx2 --image=nginx --labels=app=v1
pod/nginx2 created
$ k run nginx3 --image=nginx -l app=v1
pod/nginx3 created
$ k get po --show-labels
NAME     READY   STATUS              RESTARTS   AGE   LABELS
nginx1   1/1     Running             0          53s   app=v1
nginx2   1/1     Running             0          24s   app=v1
nginx3   0/1     ContainerCreating   0          2s    app=v1
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

Get the label 'app' for the pods (show a column with APP labels)


```
kubectl get po -L app
# or
kubectl get po --label-columns=app
```

Can also be used with deployment, service, etc. labels.

### Add an annotation 'owner: marketing' to all pods having 'app=v2' label

```
$ k annotate po -l "app=v2" owner=marketing
pod/nginx2 annotated

$ k describe po nginx2 | grep Annotations:
Annotations:  owner: marketing
```

### Check the annotations for pod nginx1 

```
kubectl annotate pod nginx1 --list

kubectl describe po nginx1 | grep -i 'annotations'

kubectl get po nginx1 -o jsonpath='{.metadata.annotations}{"\n"}'

kubectl get po nginx1 -o custom-columns=Name:metadata.name,ANNOTATIONS:metadata.annotations.description
```

### Remove the annotations for these three pods

```
$ k annotate po nginx{1..3} description-
pod/nginx1 annotated
pod/nginx2 annotated
pod/nginx3 annotated
```

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

every command needs a namespace and context to work. Defaults are used if not provided.

### Services

Kubernetes Services are implemented using iptables rules (with default config) on all nodes. Every time a Service has been altered, created, deleted or Endpoints of a Service have changed, the kube-apiserver contacts every node's kube-proxy to update the iptables rules according to the current state.

### Requests and limits 

https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

When you specify the resource `request` for Containers in a Pod, the scheduler uses this information to decide which node to place the Pod on. When you specify a resource `limit` for a Container, the kubelet enforces those limits so that the running container is not allowed to use more of that resource than the limit you set. The kubelet also reserves at least the request amount of that system resource specifically for that container to use.

If the node where a Pod is running has enough of a resource available, it's possible (and allowed) for a container to use more resource than its request for that resource specifies. However, a container is not allowed to use more than its resource limit.

The kubelet (and container runtime) enforce the limit. The runtime prevents the container from using more than the configured resource limit. For example: when a process in the container tries to consume more than the allowed amount of memory, the system kernel terminates the process that attempted the allocation, with an out of memory (OOM) error.

Limits can be implemented either reactively (the system intervenes once it sees a violation) or by enforcement (the system prevents the container from ever exceeding the limit). Different runtimes can have different ways to implement the same restrictions.

Note: If you specify a limit for a resource, but do not specify any request, and no admission-time mechanism has applied a default request for that resource, then Kubernetes copies the limit you specified and uses it as the requested value for the resource.

CPU and memory are collectively referred to as compute resources, or resources. Compute resources are measurable quantities that can be requested, allocated, and consumed. They are distinct from API resources. API resources, such as Pods and Services are objects that can be read and modified through the Kubernetes API server.

you can only specify requests and limits for individual containers. For a particular resource, a Pod resource request/limit is the sum of the resource requests/limits of that type for each container in the Pod.

The memory limit defines a memory limit for that cgroup. If the container tries to allocate more memory than this limit, the Linux kernel out-of-memory subsystem activates and, typically, intervenes by stopping one of the processes in the container that tried to allocate memory. If that process is the container's PID 1, and the container is marked as restartable, Kubernetes restarts the container.

If a container exceeds its memory request and the node that it runs on becomes short of memory overall, it is likely that the Pod the container belongs to will be evicted.

A container might or might not be allowed to exceed its CPU limit for extended periods of time. However, container runtimes don't terminate Pods or containers for excessive CPU usage.


However, if the filesystem space for writeable container layers, node-level logs, or emptyDir volumes falls low, the node taints itself as short on local storage and this taint triggers eviction for any Pods that don't specifically tolerate the taint.

Note: Extended resources cannot be overcommitted, so request and limit must be equal if both are present in a container spec.

To consume an extended resource in a Pod, include the resource name as a key in the spec.containers[].resources.limits map in the container spec.

A Pod is scheduled only if all of the resource requests are satisfied, including CPU, memory and any extended resources. The Pod remains in the PENDING state as long as the resource request cannot be satisfied.

The amount of resources available to Pods is less than the node capacity because system daemons use a portion of the available resources. Within the Kubernetes API, each Node has a .status.allocatable field. The .status.allocatable field describes the amount of resources that are available to Pods on that node (for example: 15 virtual CPUs and 7538 MiB of memory). 

You should also consider what access you grant to that namespace: full write access to a namespace allows someone with that access to remove any resource, including a configured ResourceQuota.

Per-deployment settings override the global namespace settings.


Requests are what the container is guaranteed to get. If a container requests a resource, Kubernetes will only schedule it on a node that can give it that resource. Limits, on the other hand, make sure a container never goes above a certain value.

### CRD

CRD — Custom Resource Definition — defines a Custom Resource which is not available in the default Kubernetes implementation.

The CRD alone doesn’t do anything, a controller/operator needs to be implemented to create and manage the resources for the CRD 

Each API group-version contains one or more kubernetes API types, which is called as a ‘Kind’.

A Kind consists of Metadata + Spec + Status + List. Typically the spec contains the desired state and the status contains the observed state.

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

Create a cronjob:

```
kubectl create cronjob busybox --image=busybox --schedule="*/1 * * * *" -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster'
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

### kube-proxy config files location

the kube-proxy process and its config files reside inside the kube-proxy pod.

```
gengwg@cp:~$ kubectl get pods -n kube-system -o wide | grep proxy
kube-proxy-mjrqg                           1/1     Running   1 (2d19h ago)   5d12h   10.2.0.4         cp       <none>           <none>
kube-proxy-mxx6f                           1/1     Running   1 (2d19h ago)   5d12h   10.2.0.5         worker   <none>           <none>
gengwg@cp:~$ kubectl exec -it kube-proxy-mjrqg -n kube-system -- /bin/sh
# find / -name config.conf
/var/lib/kube-proxy/config.conf
/var/lib/kube-proxy/..2021_12_08_06_04_17.573220252/config.conf
# cat /var/lib/kube-proxy/config.conf
```

### Find out what container runtime is used on a node

```
$ kubectl get nodes -o wide
NAME                 STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                     KERNEL-VERSION           CONTAINER-RUNTIME
kind-control-plane   Ready    master   246d   v1.19.1   172.18.0.2    <none>        Ubuntu Groovy Gorilla (development branch)   5.15.7-100.fc34.x86_64   containerd://1.4.0
```

### Create a pod using command line

```
controlplane ~ ➜  kubectl run nginx --image=nginx
pod/nginx created
```

### Create a pod yaml using command line

```
$ kubectl run redis --image=redis --dry-run=client -o yaml > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: redis
  name: redis
spec:
  containers:
  - image: redis
    name: redis
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Create a pod yaml with shell args:

```
$ k -n secret run secret-pod --image=busybox:1.31.1 --dry-run=client -o yaml -- sh -c "sleep 5d"
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secret-pod
  name: secret-pod
  namespace: secret
spec:
  containers:
  - args:
    - sh
    - -c
    - sleep 5d
    image: busybox:1.31.1
    name: secret-pod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Create a pod YAML template with command

```
$ kubectl run busy --image=busybox --restart=Never --dry-run=client -o yaml --command -- env 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busy
  name: busy
spec:
  containers:
  - command:
    - env
    image: busybox
    name: busy
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

Get the YAML for a new ResourceQuota called 'myrq' with hard limits of 1 CPU, 1G memory and 2 pods

```
$ k create quota myrq --hard=cpu=1,memory=1G,pods=2 --dry-run=client -o yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  creationTimestamp: null
  name: myrq
spec:
  hard:
    cpu: "1"
    memory: 1G
    pods: "2"
status: {}
```

Create a pod with image nginx called nginx and expose traffic on port 80

```
$ kubectl run nginx --image=nginx --restart=Never --port=80 --dry-run=client -o yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

Create pod with env

```
kubectl run nginx --image=nginx --restart=Never --env=var1=val1
kubectl run nginx --restart=Never --image=nginx --env=var1=val1 -it --rm -- env
```

### edit a running pod config

```
kubectl edit pod redis
```

### Scale replica set

```
# modify `replicas: 3` in the replicaset defition yaml, then replace the original replicaset:
kubectl replace -f replicaset.defition.yaml

kubectl scale --replicas=3 -f replicaset-defition.yaml

# specify type and name of the replica set.
kubectl scale --replicas=3 replicaset myapp-replicaset

# edit the replicaset
controlplane ~ ✖ kubectl edit replicasets.apps new-replica-set
```

###  Scale down StatefulSet and record an annotation

```
k8s@terminal:~$ kubectl scale  StatefulSet/o3db --replicas=1  -n project-c13 --record
```

### get resources without header

use for wc for example.

```
$ kubectl get po -n kube-system --no-headers
```

### Expose service with a name

```
kubectl expose pod messaging --name messaging-service --port 6379 --target-port 6379
```

Expose node port:

```
k expose pod my-static-pod-cluster3-master1 \
  --name static-pod-service \
  --type=NodePort \
  --port 80
```

### lists all Pods sorted by their AGE 

```
kubectl get pod -A --sort-by=.metadata.creationTimestamp
```

### lists pods sorted by their node name 

```
$ k get po -o wide --sort-by=.spec.nodeName
```

### Manual Scheduling

The only thing a scheduler does, is that it sets the nodeName for a Pod declaration. How it finds the correct node to schedule on, that's a very much complicated matter and takes many variables into account.

```
spec:
  nodeName: cluster2-master1
```

It looks like our Pod is running on the master now as requested, although no tolerations were specified. Only the scheduler takes tains/tolerations/affinity into account when finding the correct node name. That's why its still possible to assign Pods manually directly to a master node and skip the scheduler.

### bash auto-completion

```
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
```


### list all pods and its nodes

```
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --all-namespaces
kubectl get pod -o=custom-columns=NODE:.spec.nodeName,POD:.metadata.name --all-namespaces
```

### Get cluster cluster role binding for a group

```
$ kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.subjects[0].kind=="Group") | select(.subjects[0].   name=="Some-AD-Group") | .metadata.name'
```

### Accessing the API from within a Pod

```
# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api
```

### Delete Worker Nodes from Kubernetes Cluster

1. Cordon the nodes

```
kubectl cordon workernode
```

2. Drain the nodes

Drain the nodes to evict the pods currently running on the nodes. You might have to ignore daemonsets and local-data in the machine.

```
kubectl drain workernode  --delete-local-data --ignore-daemonsets --force
```

3. Delete the nodes

```
for i in {3..6}; do kubectl delete node  workernode11$i; done
```

### Run pod on specific node

```
$ kubectl run test --image=nginx:1.21.4-alpine --overrides='{"apiVersion": "v1", "spec": {"nodeSelector": { "kubernetes.io/hostname": "node1" }}}'
pod/test created
```

### To find which apiVersion to use for a resource

```
$ k api-resources |  grep pods
pods                              po           v1                                     true         Pod
```

### Create a role only create Secrets and ConfigMaps in that Namespace

```
kubectl -n project-hamster create role accessor --verb=create --resource=secret --resource=configmap
```

### Now we bind the Role to the ServiceAccount

```
k -n project-hamster create rolebinding processor \
  --role processor \
  --serviceaccount project-hamster:processor
```

### shows the latest events in the whole cluster, ordered by time.

```
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

### Write the names of all namespaced Kubernetes resources (like Pod, Secret, ConfigMap...)

```
k api-resources -h
k api-resources --namespaced -o name
```

### find out the node a pod scheduled on

```
k get po alpine -o jsonpath="{.spec.nodeName}"
```

### Lists all Pod names and their requests/limit

```
$ k get pod -o jsonpath="{range .items[*]} {.metadata.name}{.spec.containers[*].resources}{'\n'}" -n kube-system
 coredns-558bd4d5db-9wf2b{"limits":{"memory":"170Mi"},"requests":{"cpu":"100m","memory":"70Mi"}}
 coredns-558bd4d5db-td76k{"limits":{"memory":"170Mi"},"requests":{"cpu":"100m","memory":"70Mi"}}
 etcd-kind-multi-nod-control-plane{"requests":{"cpu":"100m","ephemeral-storage":"100Mi","memory":"100Mi"}}
 kindnet-4cbhq{"limits":{"cpu":"100m","memory":"50Mi"},"requests":{"cpu":"100m","memory":"50Mi"}}
 kindnet-df25z{"limits":{"cpu":"100m","memory":"50Mi"},"requests":{"cpu":"100m","memory":"50Mi"}}
 kindnet-pgjxm{"limits":{"cpu":"100m","memory":"50Mi"},"requests":{"cpu":"100m","memory":"50Mi"}}
 kube-apiserver-kind-multi-nod-control-plane{"requests":{"cpu":"250m"}}
 kube-controller-manager-kind-multi-nod-control-plane{"requests":{"cpu":"200m"}}
 kube-proxy-5ph6f{}
 kube-proxy-jd6kv{}
 kube-proxy-qffn2{}
 kube-scheduler-kind-multi-nod-control-plane{"requests":{"cpu":"100m"}}
 metrics-server-6744b4c64f-cwgnw{}

$ k describe pod -n kube-system | egrep "^(Name:|    Requests:)" -A1

# BestEffort Pods don't have any memory or cpu limits or requests defined.
$ k get pods -n kube-system -o jsonpath="{range .items[*]}{.metadata.name} {.status.qosClass}{'\n'}"
coredns-558bd4d5db-9wf2b Burstable
coredns-558bd4d5db-td76k Burstable
etcd-kind-multi-nod-control-plane Burstable
kindnet-4cbhq Guaranteed
kindnet-df25z Guaranteed
kindnet-pgjxm Guaranteed
kube-apiserver-kind-multi-nod-control-plane Burstable
kube-controller-manager-kind-multi-nod-control-plane Burstable
kube-proxy-5ph6f BestEffort
kube-proxy-jd6kv BestEffort
kube-proxy-qffn2 BestEffort
kube-scheduler-kind-multi-nod-control-plane Burstable
metrics-server-6744b4c64f-cwgnw BestEffort
```

### Check if a user/serviceaccount is allowed do run a command

```
$ k auth can-i get secret --as system:serviceaccount:project-hamster:secret-reader
yes
```

### Delete all resources using label

```
$ k run check-ip --image=httpd:2.4.41-alpine
pod/check-ip created
$ k expose pod check-ip --name check-ip-service --port 80
service/check-ip-service exposed
$ k get svc,ep -l run=check-ip
NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/check-ip-service   ClusterIP   10.96.228.166   <none>        80/TCP    7s

NAME                         ENDPOINTS        AGE
endpoints/check-ip-service   10.244.1.10:80   7s

$ k delete all -l run=check-ip
pod "check-ip" deleted
service "check-ip-service" deleted
```

### Copy file between a pod and local machine

```
# pod --> local
$ kubectl cp nginx:docker-entrypoint.sh /tmp/docker-entrypoint.sh

# local --> pod
$ kubectl cp myfile nginx:/
$ kubectl exec -it nginx -- ls /myfile
```

### To list all Pods running on a specific Node in the all Namespaces

```
$ kubectl get pods --field-selector spec.nodeName=kind-multi-nod-worker2 --all-namespaces
NAMESPACE       NAME                         READY   STATUS    RESTARTS   AGE
default         alpine                       1/1     Running   70         7d20h
default         multi-container-playground   3/3     Running   0          7d20h
kube-system     kindnet-df25z                1/1     Running   1          44d
kube-system     kube-proxy-jd6kv             1/1     Running   1          44d
project-tiger   ds-important-qqtqs           1/1     Running   0          22d
```

### Change pod's image 

Note: The RESTARTS column should contain 0 initially (ideally - it could be any number)


```
$ k get po
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          4m1s

# kubectl set image POD/POD_NAME CONTAINER_NAME=IMAGE_NAME:TAG
kubectl set image pod/nginx nginx=nginx:1.7.1
pod/nginx image updated

kubectl describe po nginx # you will see an event 'Container will be killed and recreated'
....
  Normal  Killing    12s   kubelet            Container nginx definition changed, will be restarted
  Normal  Pulling    12s   kubelet            Pulling image "nginx:1.7.1"

kubectl get po nginx -w # watch it
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   1          4m58s

# Note: you can check pod's image by running
$ kubectl get po nginx -o jsonpath='{.spec.containers[].image}{"\n"}'
nginx:1.7.1
```

### Get nginx pod's ip created in previous step, use a temp busybox image to wget its '/'

```
# manually
$ kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- 10.244.2.5:80

# advanced
# Get IP of the nginx pod
NGINX_IP=$(kubectl get pod nginx -o jsonpath='{.status.podIP}')
# create a temp busybox pod
$ kubectl run busybox --image=busybox  --rm -it --restart=Never -- wget -O- $NGINX_IP:80
# or
kubectl run busybox --image=busybox --env="NGINX_IP=$NGINX_IP" --rm -it --restart=Never -- sh -c 'wget -O- $NGINX_IP:80'

# one liner
$ kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- $(kubectl get pod nginx -o jsonpath='{.status.podIP}:{.spec.containers[0].ports[0].containerPort}')
```

### If pod crashed and restarted, get logs about the previous instance

```
kubectl logs nginx -p
# or
kubectl logs nginx --previous
```

### Create a busybox pod that echoes 'hello world' and then exits

```
kubectl run busybox --image=busybox -it --restart=Never -- echo 'hello world'
# or
kubectl run busybox --image=busybox -it --restart=Never -- /bin/sh -c 'echo hello world'
```

### Do the same, but have the pod deleted automatically when it's completed

```
kubectl run busybox --image=busybox -it --rm --restart=Never -- /bin/sh -c 'echo hello world'
```

### Create a deployment with 2 replicas

```
kubectl create deploy nginx --image=nginx:1.18.0 --replicas=2 --port=80
```

### get number of replicas

```
kubectl describe deploy nginx # you'll see the name of the replica set on the Events section and in the 'NewReplicaSet' property
# OR you can find rs directly by:
kubectl get rs -l run=nginx # if you created deployment by 'run' command
kubectl get rs -l app=nginx # if you created deployment by 'create' command
```

### Check how the deployment rollout is going

```
$ kubectl rollout status deploy nginx
deployment "nginx" successfully rolled out

$ k set image deploy nginx nginx=nginx:1.91
deployment.apps/nginx image updated
$ kubectl rollout status deploy nginx
Waiting for deployment "nginx" rollout to finish: 1 out of 2 new replicas have been updated...
```

### Check the rollout history and confirm that the replicas are OK

```
$ kubectl rollout history deploy nginx
deployment.apps/nginx 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

$ kubectl get deploy nginx
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     2            2           9m51s
$ kubectl get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx-575fc7645b   2         2         1       23s
nginx-67dfd6c8f9   1         1         1       9m55s
$ kubectl get po
NAME                     READY   STATUS    RESTARTS   AGE
nginx-575fc7645b-wtmsh   1/1     Running   0          30s
nginx-575fc7645b-zq9x5   1/1     Running   0          17s

$ kubectl rollout history deploy nginx --revision=4
deployment.apps/nginx with revision #4
Pod Template:
  Labels:	app=nginx
	pod-template-hash=d645d84b6
  Containers:
   nginx:
    Image:	nginx:1.91
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
```

### Undo the latest rollout 

```
$ kubectl rollout undo deploy nginx
deployment.apps/nginx rolled back
$ k get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx-575fc7645b   1         1         1       2m24s
nginx-67dfd6c8f9   2         2         1       11m
$ k get po
NAME                     READY   STATUS        RESTARTS   AGE
nginx-575fc7645b-zq9x5   0/1     Terminating   0          2m14s
nginx-67dfd6c8f9-69p8l   1/1     Running       0          4s
nginx-67dfd6c8f9-jpcrr   1/1     Running       0          5s
$ k get po
NAME                     READY   STATUS    RESTARTS   AGE
nginx-67dfd6c8f9-69p8l   1/1     Running   0          8s
nginx-67dfd6c8f9-jpcrr   1/1     Running   0          9s
gengwg@elaine:~/nc$ k get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx-575fc7645b   0         0         0       2m46s
nginx-67dfd6c8f9   2         2         2       12m
```

### Pause/resume rollout

```
$ kubectl rollout pause deploy nginx
deployment.apps/nginx paused

$ kubectl rollout resume deploy nginx
deployment.apps/nginx resumed
```

### Autoscale the deployment, targetting cpu utilization at 80 percent

```
$ kubectl autoscale deploy nginx --min=7 --max=10 --cpu-percent=80
horizontalpodautoscaler.autoscaling/nginx autoscaled

$ k get hpa nginx
NAME    REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
nginx   Deployment/nginx   <unknown>/80%   7         10        0          15s
```

### Create a job

```
$ kubectl create job busybox --image=busybox -- /bin/sh -c 'echo hello;sleep 30;echo world'
job.batch/busybox created
$ kubectl logs job/busybox
hello
# wait 30 seconds
$ kubectl logs job/busybox
hello
world
```

### Check PVC usage

by run `df -h` inside a container:

```
k exec -it prometheus-prom-prometheus-0 -- df -h /prometheus
```

### Randomly choose a Ready node

```
kubectl get nodes --no-headers | grep -v NotReady | awk '{print $1}' | shuf -n1
```

### view the events for a Pod

```
kubectl describe pod frontend | grep -A 9999999999 Events
```

## Troubleshooting

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

### WARNING: Kubernetes configuration file is group-readable. This is insecure. 

```
gengwg@gengwg-mbp:~$ helm template myprom prometheus-community/kube-prometheus-stack -n monitoring > k8s-myprom.yaml
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /Users/gengwg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /Users/gengwg/.kube/config
```

===>

Your `~/.kube/config` should only be readable by you. Use chmod to change the file's read/write permissions.

#### Before

```
gengwg@gengwg-mbp:~$ ll .kube/
total 48
drwxr-x---  4 gengwg  staff   128 Apr 16  2021 cache
-rw-r--r--  1 gengwg  staff  7751 Nov 22 16:16 config
```

#### After

```
gengwg@gengwg-mbp:~/.kube$ chmod 0600 config
gengwg@gengwg-mbp:~/.kube$ ll config
-rw-------  1 gengwg  staff  7751 Nov 22 16:16 config
```

### “kubectl get no” command is not showing master nodes

it looks like kubelet is not deployed onto the master nodes. This would be the reason why they don’t show up in a kubectl get nodes command.

Because the kubectl command is working it tells me the api servers are running fine.

### the server rejected our request for an unknown reason

```
$ k get no
Error from server (BadRequest): the server rejected our request for an unknown reason
```

It was because I accidentally specified http instead of https. you need to specify https in `clusters[].cluster.server`.

```
    server: k8s.example.com:6443
```

### My Pods are pending with event message FailedScheduling 

In general, if a Pod is pending with a message of this type, there are several things to try:

    Add more nodes to the cluster.
    Terminate unneeded Pods to make room for pending Pods.
    Check that the Pod is not larger than all the nodes. For example, if all the nodes have a capacity of cpu: 1, then a Pod with a request of cpu: 1.1 will never be scheduled.
    Check for node taints. If most of your nodes are tainted, and the new Pod does not tolerate that taint, the scheduler only considers placements onto the remaining nodes that don't have that taint.

## Resources

- https://github.com/kelseyhightower/kubernetes-the-hard-way

