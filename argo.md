# Install
```
kubectl create namespace argo

gengwg@gengwg-mbp:~$ kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.8/install.yaml
customresourcedefinition.apiextensions.k8s.io/clusterworkflowtemplates.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/cronworkflows.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/workflowartifactgctasks.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/workfloweventbindings.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/workflows.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/workflowtaskresults.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/workflowtasksets.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/workflowtemplates.argoproj.io created
serviceaccount/argo created
serviceaccount/argo-server created
role.rbac.authorization.k8s.io/argo-role created
clusterrole.rbac.authorization.k8s.io/argo-aggregate-to-admin created
clusterrole.rbac.authorization.k8s.io/argo-aggregate-to-edit created
clusterrole.rbac.authorization.k8s.io/argo-aggregate-to-view created
clusterrole.rbac.authorization.k8s.io/argo-cluster-role created
clusterrole.rbac.authorization.k8s.io/argo-server-cluster-role created
rolebinding.rbac.authorization.k8s.io/argo-binding created
clusterrolebinding.rbac.authorization.k8s.io/argo-binding created
clusterrolebinding.rbac.authorization.k8s.io/argo-server-binding created
configmap/workflow-controller-configmap created
service/argo-server created
priorityclass.scheduling.k8s.io/workflow-controller created
deployment.apps/argo-server created
deployment.apps/workflow-controller created
gengwg@gengwg-mbp:~$ kubectl patch deployment \
>   argo-server \
>   --namespace argo \
>   --type='json' \
>   -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
>   "server",
>   "--auth-mode=server"
> ]}]'
deployment.apps/argo-server patched
gengwg@gengwg-mbp:~$ kubectl -n argo port-forward deployment/argo-server 2746:2746
error: unable to forward port because pod is not running. Current status=Pending
gengwg@gengwg-mbp:~$
gengwg@gengwg-mbp:~$ k get all -n argo
NAME                                       READY   STATUS    RESTARTS   AGE
pod/argo-server-5f9cc77449-wmg8z           0/1     Running   0          16s
pod/argo-server-8698df74c9-9rxqp           0/1     Running   0          23s
pod/workflow-controller-7c494c456b-m89f5   1/1     Running   0          23s

NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/argo-server   ClusterIP   10.96.201.89   <none>        2746/TCP   23s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/argo-server           0/1     1            0           23s
deployment.apps/workflow-controller   1/1     1            1           23s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/argo-server-5f9cc77449           1         1         0       16s
replicaset.apps/argo-server-8698df74c9           1         1         0       23s
replicaset.apps/workflow-controller-7c494c456b   1         1         1       23s

gengwg@gengwg-mbp:~$ kubectl -n argo port-forward deployment/argo-server 2746:2746
Forwarding from 127.0.0.1:2746 -> 2746
Forwarding from [::1]:2746 -> 2746

# Install Argo CLI

# Download the binary
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.4.8/argo-darwin-amd64.gz

# Unzip
gunzip argo-darwin-amd64.gz

# Make binary executable
chmod +x argo-darwin-amd64

# Move binary to path
sudo mv ./argo-darwin-amd64 /usr/local/bin/argo

# Test installation
argo version

gengwg@gengwg-mbp:~$ curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.4.8/argo-darwin-amd64.gz

# Unzip
gunzip argo-darwin-amd64.gz

# Make binary executable
chmod +x argo-darwin-amd64

# Move binary to path
sudo mv ./argo-darwin-amd64 /usr/local/bin/argo

# Test installation
argo version


gengwg@gengwg-mbp:~$ # Download the binary
gengwg@gengwg-mbp:~$ curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.4.8/argo-darwin-amd64.gz

# Unzip
gunzip argo-darwin-amd64.gz

# Make binary executable
chmod +x argo-darwin-amd64

# Move binary to path
sudo mv ./argo-darwin-amd64 /usr/local/bin/argo

# Test installation
argo version
gengwg@gengwg-mbp:~$
gengwg@gengwg-mbp:~$ # Unzip
gengwg@gengwg-mbp:~$ gunzip argo-darwin-amd64.gz
gengwg@gengwg-mbp:~$
gengwg@gengwg-mbp:~$ # Make binary executable
gengwg@gengwg-mbp:~$ chmod +x argo-darwin-amd64
gengwg@gengwg-mbp:~$
gengwg@gengwg-mbp:~$ # Move binary to path
gengwg@gengwg-mbp:~$ sudo mv ./argo-darwin-amd64 /usr/local/bin/argo
gengwg@gengwg-mbp:~$
gengwg@gengwg-mbp:~$ # Test installation
gengwg@gengwg-mbp:~$ argo version
argo: v3.4.8
  BuildDate: 2023-05-25T23:14:36Z
  GitCommit: 9e27baee4b3be78bb662ffa5e3a06f8a6c28fb53
  GitTreeState: clean
  GitTag: v3.4.8
  GoVersion: go1.20.4
  Compiler: gc
  Platform: darwin/amd64

argo submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml


STEP                  TEMPLATE  PODNAME            DURATION  MESSAGE
 ◷ hello-world-5p8f4  whalesay  hello-world-5p8f4  47s       PodInitializing
Name:                hello-world-5p8f4
Namespace:           argo
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Mon Aug 07 18:15:24 -0700 (47 seconds ago)
Started:             Mon Aug 07 18:15:24 -0700 (47 seconds ago)
Finished:            Mon Aug 07 18:16:11 -0700 (now)
Duration:            47 seconds
Progress:            1/1
ResourcesDuration:   26s*(100Mi memory),26s*(1 cpu)

STEP                  TEMPLATE  PODNAME            DURATION  MESSAGE
 ✔ hello-world-5p8f4  whalesay  hello-world-5p8f4  38s
gengwg@gengwg-mbp:~$
gengwg@gengwg-mbp:~$ argo list -n argo
NAME                STATUS      AGE   DURATION   PRIORITY   MESSAGE
hello-world-5p8f4   Succeeded   51s   47s        0

gengwg@gengwg-mbp:~$ argo get -n argo @latest
Name:                hello-world-5p8f4
Namespace:           argo
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Mon Aug 07 18:15:24 -0700 (1 minute ago)
Started:             Mon Aug 07 18:15:24 -0700 (1 minute ago)
Finished:            Mon Aug 07 18:16:11 -0700 (49 seconds ago)
Duration:            47 seconds
Progress:            1/1
ResourcesDuration:   26s*(1 cpu),26s*(100Mi memory)

STEP                  TEMPLATE  PODNAME            DURATION  MESSAGE
 ✔ hello-world-5p8f4  whalesay  hello-world-5p8f4  38s

gengwg@gengwg-mbp:~$ argo logs -n argo @latest
hello-world-5p8f4:  _____________
hello-world-5p8f4: < hello world >
hello-world-5p8f4:  -------------
hello-world-5p8f4:     \
hello-world-5p8f4:      \
hello-world-5p8f4:       \
hello-world-5p8f4:                     ##        .
hello-world-5p8f4:               ## ## ##       ==
hello-world-5p8f4:            ## ## ## ##      ===
hello-world-5p8f4:        /""""""""""""""""___/ ===
hello-world-5p8f4:   ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
hello-world-5p8f4:        \______ o          __/
hello-world-5p8f4:         \    \        __/
hello-world-5p8f4:           \____\______/
hello-world-5p8f4: time="2023-08-08T01:16:01.852Z" level=info msg="sub-process exited" argo=true error="<nil>"
```

