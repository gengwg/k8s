This is an tutorial/example for building Docker images and pushing to image registry inside the Kubernetes cluster using Kaniko.

# Minikube + Public Docker Hub

## Prepare the local mounted directory

Create a local directory which will be mounted in kaniko container as build context. Create a simple dockerfile there like this:

```
$ minikube ssh
docker@minikube:~$ mkdir kaniko && cd kaniko
docker@minikube:~/kaniko$
docker@minikube:~/kaniko$ echo 'FROM ubuntu' >> dockerfile
docker@minikube:~/kaniko$ echo 'ENTRYPOINT ["/bin/bash", "-c", "echo hello"]' >> dockerfile
docker@minikube:~/kaniko$ cat dockerfile
FROM ubuntu
ENTRYPOINT ["/bin/bash", "-c", "echo hello"]
docker@minikube:~/kaniko$ pwd
/home/docker/kaniko
```

### Create a Secret that holds your authorization token

Generate a Docker hub token here:

https://hub.docker.com/settings/security?generateToken=true

When logging in from your Docker CLI client, use this token as a password.

To use the access token from your Docker CLI client:

1. Run docker login -u <your username>

2. At the password prompt, enter the personal access token.


```
$ docker login -u username
Password:
Login Succeeded
```

Logging in with your password grants your terminal complete access to your account.

For better security, log in with a limited-privilege personal access token. Learn more at https://docs.docker.com/go/access-tokens/

Format:

```
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

To find docker-server:

```
gengwg@gengwg-mbp:~$ docker info | grep Registry:
 Registry: https://index.docker.io/v1/
```

## Create resources in kubernetes

Prepare several config files to create resources in kubernetes, which are:

- pod.yaml is for starting a kaniko container to build the example image.
- volume.yaml is for creating a persistent volume used as kaniko build context.
- volume-claim.yaml is for creating a persistent volume claim which will mounted in the kaniko container.

```
$ kubectl create -f volume.yaml
$ kubectl create -f volume-claim.yaml
$ k apply -f pod.yaml
pod/kaniko created
```

## Verify image uploaded

Check logs:

```
$ k logs kaniko
INFO[0001] Retrieving image manifest ubuntu
INFO[0001] Retrieving image ubuntu from registry index.docker.io
INFO[0002] Built cross stage deps: map[]
INFO[0002] Retrieving image manifest ubuntu
INFO[0002] Returning cached image manifest
INFO[0002] Executing 0 build triggers
INFO[0002] Building stage 'ubuntu' [idx: '0', base-idx: '-1']
INFO[0002] Skipping unpacking as no commands require it.
INFO[0002] ENTRYPOINT ["/bin/bash", "-c", "echo hello"]
INFO[0002] Pushing image to gengwg807/ubuntu
INFO[0004] Pushed index.docker.io/gengwg807/ubuntu@sha256:b5f229e3f4a7a8196ba4109e04fc24417508a6cc013ed98e1fe7568d612e50c0
```

Check here the image has been pushed:

https://hub.docker.com/repositories/username


# Kubernetes + Private DTR

## Prepare the local mounted directory

Create a local directory which will be mounted in kaniko container as build context. Create a simple dockerfile there like this:

```
$ cat dockerfile
FROM dtr.example.com/gengwg/alpine
ENTRYPOINT ["/bin/sh", "-c", "echo hello world from kaniko"]
```

To use a local directory build context, you could consider using configMaps to mount in small build contexts. Or use PVC?

## Create a Secret that holds your authorization token

Go to:

https://dtr.example.com/users/gengwg/access-tokens/new

```
kubectl create secret docker-registry regcred --docker-server=dtr.example.com --docker-username=gengwg --docker-password=<copied token from above> --docker-email=user@example.com
secret/regcred created
```

## Create resources in kubernetes

```
$ kubectl create -f volume.yaml
persistentvolume/dockerfile created
$ kubectl create -f volume-claim.yaml
$ k apply -f pod.yaml
pod/kaniko created
```

Some differences with above:

- hostPath is NFS now.

```
  hostPath:
    path: <nfs path containing dockerfile>
```

- use Flag `--skip-tls-verify` since our DTR CA is not mounted.

```
    args: ["--dockerfile=/workspace/dockerfile",
            "--context=dir://workspace",
            "--skip-tls-verify", # <------
....
```

## Verify

Next go to DTR, you will find a repo like this. That shows the build and push is successful.

https://dtr.example.com/repositories/gengwg/kaniko-test/

(It has the tag latest, because you didn't give any tag. Default to latest).

One can also verify the image is available for running kubectl run on it:

```
$ kubectl run mytest --image=dtr.example.com/gengwg/kaniko-test
pod/mytest created
$ k logs mytest
hello world from kaniko
```

That's it!

## Troubleshooting

If you see below error:

```
$ k logs -f kaniko
error pushing image: failed to push to destination dtr.example.com/gengwg/kaniko-test: PUT https://dtr.example.com/v2/gengwg/kaniko-test/manifests/latest: UNKNOWN: unknown error; map[]
```

The Immutability must be Off, if you are pushing the same tag (e.g. 'Latest'). Change it here:

https://dtr.example.com/repositories/gengwg/kaniko-test/settings
