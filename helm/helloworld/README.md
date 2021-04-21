```
$ helm install helloworld .
NAME: helloworld
LAST DEPLOYED: Wed Apr 21 11:39:14 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ k get po
NAME                       READY   STATUS    RESTARTS   AGE
alpine                     1/1     Running   371        27d
helloworld                 0/1     Pending   0          69s
podinfo-7466f7f75b-lfb2p   1/1     Running   1          27d
podinfo-7466f7f75b-wdj62   1/1     Running   1          27d

$ k describe po helloworld
Name:         helloworld
Namespace:    default
Priority:     0
Node:         <none>
Labels:       app.kubernetes.io/managed-by=Helm
Annotations:  meta.helm.sh/release-name: helloworld
              meta.helm.sh/release-namespace: default
Status:       Pending
IP:
IPs:          <none>
Containers:
  hello:
    Image:      alpine
    Port:       <none>
    Host Port:  <none>
    Command:
      /bin/sh
      -c
    Args:
      /bin/echo Hello! My company name is ABC Company
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-kmxj5 (ro)
Volumes:
  default-token-kmxj5:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-kmxj5
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:          <none>

$ k logs -f helloworld
Hello! My company name is ABC Company

$ helm delete helloworld
release "helloworld" uninstalled
$ k get po
NAME                       READY   STATUS    RESTARTS   AGE
alpine                     1/1     Running   371        27d
podinfo-7466f7f75b-lfb2p   1/1     Running   1          27d
podinfo-7466f7f75b-wdj62   1/1     Running   1          27d
```


We will first replace the original template with our new template, then install it with Helm and verify.

```
$ mv templates templates_old
$ mv templates_new/ templates
$ Helm delete helloworld
$ Helm install helloworld .
$ k logs -f helloworld
My name is Gary. I work for Marketing department. Our company name is ABC Company
```
