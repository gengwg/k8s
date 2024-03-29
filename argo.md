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

# Test

```
$ cat argo-workflow-example.yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: ip-processing-dag-
  namespace: gengwg
spec:
  entrypoint: data-processing-example
  volumeClaimTemplates:                 # define volume, same syntax as Kubernetes pod spec
  - metadata:
      name: workdir                     # name of volume claim
      labels:
        oncall: my_oncall
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi                  # Gi => 1024 * 1024 * 1024
      storageClassName: mysc-system

  templates:
  - name: data-processing-example
    dag:
      tasks:
        - name: generate-ips
          template: generate
        - name: process-ips
          template: process
          dependencies:
            - generate-ips
        - name: delete-ips
          template: delete
          dependencies:
            - process-ips

  - name: generate
    container:
      image: hbr.my.com/my/whalesay:latest
      command: [sh, -c]
      args: ['for i in {1..100}; do echo "192.168.0.$i" >> /mnt/vol/ips.txt; echo "192.168.0.$i" >> /mnt/vol/ips.txt; done']
      volumeMounts:
      - name: workdir
        mountPath: /mnt/vol

  - name: process
    container:
      image: hbr.my.com/gengwg/alpine
      command: [ sh, -c ]
      args: [ 'cat /mnt/vol/ips.txt | sort | uniq -d' ]
      volumeMounts:
        - name: workdir
          mountPath: /mnt/vol

  - name: delete
    container:
      image: hbr.my.com/gengwg/alpine
      command: [sh, -c]
      args: ["echo deleting file from volume; find /mnt/vol; rm /mnt/vol/ips.txt"]
      volumeMounts:                     # same syntax as Kubernetes pod spec
      - name: workdir
        mountPath: /mnt/vol
```

# Troubleshooting

## Fix Argo executor image 

```
  Normal   Pulling                 21s   kubelet                  Pulling image "quay.io/argoproj/argoexec:v3.4.8"
  Warning  Failed                  6s    kubelet                  Failed to pull image "quay.io/argoproj/argoexec:v3.4.8": rpc error: code = Unknown desc = Error response from daemon: Get "https://quay.io/v2/": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
  Warning  Failed                  6s    kubelet                  Error: ErrImagePull
  Normal   BackOff                 6s    kubelet                  Back-off pulling image "quay.io/argoproj/argoexec:v3.4.8"
  Warning  Failed                  6s    kubelet                  Error: ImagePullBackOff
```

The executor image is unaccessible from internal network.

First push that image to internal registry

```
gengwg@gengwg-mbp:~$ docker pull --platform=linux/amd64 quay.io/argoproj/argoexec:v3.4.8
gengwg@gengwg-mbp:~$ docker tag quay.io/argoproj/argoexec:v3.4.8 hbr.my.com/gengwg/argoexec:v3.4.8
gengwg@gengwg-mbp:~$ docker push hbr.my.com/gengwg/argoexec:v3.4.8
```

```
$ vim argo-install.yaml
....
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: workflow-controller
  namespace: argo
spec:
  selector:
    matchLabels:
      app: workflow-controller
  template:
    metadata:
      labels:
        app: workflow-controller
    spec:
      containers:
      #- args: []
      - args:
        - --executor-image
        - quay.io/argoproj/argoexec:latest # change to internal image: hbr.my.com/gengwg/argoexec:v3.4.8
        command:
....
```

Then reapply:

```
$ kaf argo-install.yaml
```

Need patch again since it's a new deployment. otherwise get:

```
If your organisation has configured client authentication, get your token following this instructions from here and paste in this box:
```

```
$ kubectl patch deployment \
>   argo-server \
>   --namespace argo \
>   --type='json' \
>   -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
>   "server",
>   "--auth-mode=server"
> ]}]'

deployment.apps/argo-server patched
```

Now same workflow as on laptop:

```
$ kubectl -n argo port-forward deployment/argo-server 2746:2746
```

You can see  the jobs all succeeded:

```
$ k get po -n gengwg | grep ip
ip-processing-dag-82b5g-delete-779236722      0/2     Completed               0               39s
ip-processing-dag-82b5g-generate-2784098314   0/2     Completed               0               93s
ip-processing-dag-82b5g-process-1879190736    0/2     Completed               0               60s
```
