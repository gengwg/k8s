Pull an Image from a Private Registry

## Log in to Docker Hub

```
$ docker login 
Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /home/gengwg/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

The login process creates or updates a config.json file that holds an authorization token. Review how Kubernetes interprets this file.

```
$ cat /home/gengwg/.docker/config.json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "XXXXXXXX=="
		}
	}
```

## Create a Secret based on existing credentials 

A Kubernetes cluster uses the Secret of `kubernetes.io/dockerconfigjson` type to authenticate with a container registry to pull a private image.

```
$ kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/home/gengwg/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
secret/regcred created

$ kubectl get secret regcred --output=yaml
apiVersion: v1
data:
  .dockerconfigjson: YYYYYYYYYYYYYYYYYYYYYYYYYYYY=
kind: Secret
metadata:
  creationTimestamp: "2022-11-21T02:08:47Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:.dockerconfigjson: {}
      f:type: {}
    manager: kubectl-create
    operation: Update
    time: "2022-11-21T02:08:47Z"
  name: regcred
  namespace: default
  resourceVersion: "625"
  uid: 631e77e3-9086-423b-95a7-72d44b583f67
type: kubernetes.io/dockerconfigjson
```

To understand what is in the .dockerconfigjson field, convert the secret data to a readable format:

```
$ kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "XXXXXXXXX=="
		}
	}
}
```
The auth field is your username and password concatenated with a :

```
$ echo "XXXXXXXXX==" | base64 --decode
gengwg:xxxxxxxxxxx
```

NOTE: This will expose your credentials to the kubernetes cluster. Better use some shared account credentials.

## Create a Pod that uses your Secret 

Let's test if you don't supply image pull secrets:

```
$ cat private-reg-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: gengwg/cheers2019:latest
  # imagePullSecrets:
  # - name: regcred
```

Confirmed you can't pull image from private registry:

```
$ k apply -f private-reg-pod.yaml 
pod/private-reg created
$ k get po
NAME          READY   STATUS         RESTARTS   AGE
private-reg   0/1     ErrImagePull   0          2s

$ k get event --field-selector involvedObject.name=private-reg
LAST SEEN   TYPE      REASON      OBJECT            MESSAGE
99s         Normal    Scheduled   pod/private-reg   Successfully assigned default/private-reg to kind-control-plane
6s          Normal    Pulling     pod/private-reg   Pulling image "gengwg/cheers2019:latest"
5s          Warning   Failed      pod/private-reg   Failed to pull image "gengwg/cheers2019:latest": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/gengwg/cheers2019:latest": failed to resolve reference "docker.io/gengwg/cheers2019:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
5s          Warning   Failed      pod/private-reg   Error: ErrImagePull
19s         Normal    BackOff     pod/private-reg   Back-off pulling image "gengwg/cheers2019:latest"
19s         Warning   Failed      pod/private-reg   Error: ImagePullBackOff
```

Create a Pod that uses your Secret, and verify that the Pod is running:

```
$ cat private-reg-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: gengwg/cheers2019:latest
  imagePullSecrets:
  - name: regcred

gengwg@elaine:~/nc/github/k8s/examples$ k apply -f private-reg-pod.yaml 
pod/private-reg created
gengwg@elaine:~/nc/github/k8s/examples$ k get po
NAME          READY   STATUS    RESTARTS   AGE
private-reg   1/1     Running   0          4s

$ k get event --field-selector involvedObject.name=private-reg
LAST SEEN   TYPE      REASON      OBJECT            MESSAGE
3m13s       Normal    Scheduled   pod/private-reg   Successfully assigned default/private-reg to kind-control-plane
100s        Normal    Pulling     pod/private-reg   Pulling image "gengwg/cheers2019:latest"
99s         Warning   Failed      pod/private-reg   Failed to pull image "gengwg/cheers2019:latest": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/gengwg/cheers2019:latest": failed to resolve reference "docker.io/gengwg/cheers2019:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
99s         Warning   Failed      pod/private-reg   Error: ErrImagePull
70s         Normal    BackOff     pod/private-reg   Back-off pulling image "gengwg/cheers2019:latest"
85s         Warning   Failed      pod/private-reg   Error: ImagePullBackOff
9s          Normal    Scheduled   pod/private-reg   Successfully assigned default/private-reg to kind-control-plane
4s          Normal    Pulling     pod/private-reg   Pulling image "gengwg/cheers2019:latest"
6s          Normal    Pulled      pod/private-reg   Successfully pulled image "gengwg/cheers2019:latest" in 2.747924492s
4s          Normal    Created     pod/private-reg   Created container private-reg-container
3s          Normal    Started     pod/private-reg   Started container private-reg-container
4s          Normal    Pulled      pod/private-reg   Successfully pulled image "gengwg/cheers2019:latest" in 731.703754ms
1s          Warning   BackOff     pod/private-reg   Back-off restarting failed container
```
