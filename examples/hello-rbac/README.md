# A Hello World Example for Configuring RBAC in your Kubernetes Cluster

This creates a user with full access to her own namespace, but not any other namespace.

- Start Minikube with RBAC Enabled

```
gengwg@gengwg-mbp:~$ minikube start --extra-config=apiserver.authorization-mode=RBAC
😄  minikube v1.19.0 on Darwin 11.3
✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🏃  Updating the running docker "minikube" container ...
🐳  Preparing Kubernetes v1.20.2 on Docker 20.10.5 ...
    ▪ apiserver.authorization-mode=RBAC
🔎  Verifying Kubernetes components...
    ▪ Using image kubernetesui/dashboard:v2.1.0
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
    ▪ Using image k8s.gcr.io/metrics-server/metrics-server:v0.4.2
    ▪ Using image kubernetesui/metrics-scraper:v1.0.4
🌟  Enabled addons: storage-provisioner, metrics-server, default-storageclass, dashboard
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

- Create the user namespace

```
gengwg@gengwg-mbp:~/jane-certs$ kubectl create namespace jane
namespace/jane created
```

- Create a private key for your user

```
gengwg@gengwg-mbp:~/jane-certs$ openssl genrsa -out jane.key 2048
Generating RSA private key, 2048 bit long modulus
..............+++
.....................+++
e is 65537 (0x10001)
```

This will generate a key for the user:

```
gengwg@gengwg-mbp:~/jane-certs$ ls
jane.key
```

- Create a certificate sign request using the private key you just created.

CN name must be the same as user name (jane).

```
gengwg@gengwg-mbp:~/jane-certs$ openssl req -new -key jane.key -out jane.csr -subj "/CN=jane/O=xyz"
```

This will create the CSR file:

```
gengwg@gengwg-mbp:~/jane-certs$ ll
total 16
-rw-r--r--  1 gengwg  staff   907 Apr 30 16:04 jane.csr
-rw-r--r--  1 gengwg  staff  1679 Apr 30 16:03 jane.key
```

- Generate the final certificate by approving the certificate sign request:

```
gengwg@gengwg-mbp:~$ export CA_LOCATION=~/.minikube/
gengwg@gengwg-mbp:~/jane-certs$ openssl x509 -req -in jane.csr -CA $CA_LOCATION/ca.crt -CAkey $CA_LOCATION/ca.key -CAcreateserial -out jane.crt
Signature ok
subject=/CN=jane/O=xyz
Getting CA Private Key
gengwg@gengwg-mbp:~/jane-certs$ ll
total 24
-rw-r--r--  1 gengwg  staff   993 Apr 30 16:05 jane.crt # <-----
-rw-r--r--  1 gengwg  staff   907 Apr 30 16:04 jane.csr
-rw-r--r--  1 gengwg  staff  1679 Apr 30 16:03 jane.key
```

- Create the user using above credentials:

```
gengwg@gengwg-mbp:~/jane-certs$ kubectl config set-credentials jane --client-certificate=/Users/gengwg/jane-certs/jane.crt  --client-key=/Users/gengwg/jane-certs/jane.key
User "jane" set
```

This will create in your `.kube/config` file:

```
users:
- name: jane
  user:
    client-certificate: /Users/gengwg/jane-certs/jane.crt
    client-key: /Users/gengwg/jane-certs/jane.key
```

- Add a new context for your new user

```
gengwg@gengwg-mbp:~/jane-certs$ kubectl config set-context jane-context --cluster=minikube --namespace=jane --user=jane
Context "jane-context" created
```

This will create in your `.kube/config` file:

```
contexts:
- context:
    cluster: minikube
    namespace: jane
    user: jane
  name: jane-context
```

```
gengwg@gengwg-mbp:~/hello-rbac$ kubectx
jane-context
kind-kind
minikube
```

- Create the role for managing deployments:

```
$ cat role-deployment-manager.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: jane
  name: deployment-manager
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
gengwg@gengwg-mbp:~/hello-rbac$ k create -f role-deployment-manager.yaml
Warning: rbac.authorization.k8s.io/v1beta1 Role is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 Role
role.rbac.authorization.k8s.io/deployment-manager created
```

- Bind the subject user to the role:

```
$ cat rolebinding-deployment-manager.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: deployment-manager-binding
  namespace: jane
subjects:
- kind: User
  name: jane
  apiGroup: ""
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: ""
gengwg@gengwg-mbp:~/hello-rbac$ k create -f rolebinding-deployment-manager.yaml
Warning: rbac.authorization.k8s.io/v1beta1 RoleBinding is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 RoleBinding
rolebinding.rbac.authorization.k8s.io/deployment-manager-binding created
```

- Test the RBAC Rule.

Can do anything in jane namespace:

```
gengwg@gengwg-mbp:~/jane-certs$ kubectl --context=jane-context get pods
No resources found in jane namespace.
gengwg@gengwg-mbp:~/jane-certs$ kubectl --context=jane-context run --image bitnami/dokuwiki mydokuwiki
pod/mydokuwiki created
gengwg@gengwg-mbp:~/jane-certs$ kubectl --context=jane-context get po
NAME         READY   STATUS    RESTARTS   AGE
mydokuwiki   0/1     Pending   0          21s
gengwg@gengwg-mbp:~/jane-certs$ kubectl --context=jane-context delete po mydokuwiki
pod "mydokuwiki" deleted
gengwg@gengwg-mbp:~/jane-certs$ kubectl --context=jane-context get po
No resources found in jane namespace.
# or use --user
gengwg@gengwg-mbp:~/hello-rbac$ k --user=jane get no
Error from server (Forbidden): nodes is forbidden: User "jane" cannot list resource "nodes" in API group "" at the cluster scope
gengwg@gengwg-mbp:~/hello-rbac$ k --user=jane get po
Error from server (Forbidden): pods is forbidden: User "jane" cannot list resource "pods" in API group "" in the namespace "default"
```

Can't access things in other namespace:

```
gengwg@gengwg-mbp:~/hello-rbac$ kubectl --context=jane-context get po -n default
Error from server (Forbidden): pods is forbidden: User "jane" cannot list resource "pods" in API group "" in the namespace "default"
```

- Delete user

Delete user after done.

```
gengwg@gengwg-mbp:~$ k config delete-user jane
deleted user jane from /Users/gengwg/.kube/config
gengwg@gengwg-mbp:~$ k config delete-context jane-context
deleted context jane-context from /Users/gengwg/.kube/config
```

- Automate the process

Here is a bash script to automate the user creation process:

```
$ ./minikube-create-user.sh
usage: ./minikube-create-user.sh <username>
```

Example:

```
$ bash minikube-create-user.sh bob
namespace/bob created
Generating RSA private key, 2048 bit long modulus
.............................................................+++
.....................................+++
e is 65537 (0x10001)
Signature ok
subject=/CN=bob/O=xyz
Getting CA Private Key
User "bob" set.
Context "bob-context" created.
```

Check the user has been created:

```
gengwg@gengwg-mbp:~/hello-rbac$ grep bob -B 2 ~/.kube/config
- context:
    cluster: minikube
    namespace: bob
    user: bob
  name: bob-context
--
preferences: {}
users:
- name: bob
--
  user:
    client-certificate: /Users/gengwg/hello-rbac/bob.crt
    client-key: /Users/gengwg/hello-rbac/bob.key
```

Next modify the yamls to use new user name then run:

```
k create -f role-deployment-manager.yaml
k create -f rolebinding-deployment-manager.yaml
```

- Original Author:

https://docs.bitnami.com/tutorials/configure-rbac-in-your-kubernetes-cluster/

