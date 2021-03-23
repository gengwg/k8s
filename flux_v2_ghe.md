# Flux v2 Using KIND and Github Enterprise

This is very similar to Github in last article. Just a few option differences.

## Get GHE personal access token

Get GHE personal access token here. Check all permissions under repo.

https://my-github-enterprise.com/settings/tokens

Export them:

```
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```

## Install Flux

Command to use:

```
flux bootstrap github \
  --hostname=my-github-enterprise.com \
  --ssh-hostname=my-github-enterprise.com \
  --owner=my-github-organization \
  --repository=flux-test \
  --branch=master \
  --path=clusters/my-cluster
  --token-auth
```

Sample output:

```
$ flux bootstrap github   --hostname=my-github-enterprise.com   --ssh-hostname=my-github-enterprise.com   --owner=my-github-organization   --repository=flux-test   --branch=master   --path=clusters/my-cluster --token-auth
► connecting to my-github-enterprise.com
✔ repository cloned
✚ generating manifests
✔ components manifests pushed
► configuring deploy key
► generating sync manifests
✔ sync manifests pushed
► applying sync manifests
◎ waiting for cluster sync
✔ bootstrap finished
```

This creates:

https://my-github-enterprise.com/my-github-organization/flux-test

## Trigger  a deployment by commiting to the repo

```
/flux-test/clusters/my-cluster$ cat flux-test/alpine2-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-ghe
  namespace: default
spec:
  containers:
  - image: alpine:3.2
    command:
      - /bin/sh
      - "-c"
      - "sleep 60m"
    imagePullPolicy: IfNotPresent
    name: alpine-ghe
  restartPolicy: Always
/flux-test/clusters/my-cluster$ cat flux-test/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: alpine-ghe
  namespace: default
resources:
  - alpine2-pod.yaml
$ git clone git@my-github-enterprise.com:my-github-organization/flux-test.git
$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	renamed:    alpine2-pod.yaml -> flux-test/alpine2-pod.yaml
	renamed:    kustomization.yaml -> flux-test/kustomization.yaml

/flux-test/clusters/my-cluster$ git commit -am 'move to a folder'
[master a64aa66] move to a folder
 2 files changed, 0 insertions(+), 0 deletions(-)
 rename clusters/my-cluster/{ => flux-test}/alpine2-pod.yaml (100%)
 rename clusters/my-cluster/{ => flux-test}/kustomization.yaml (100%)
/flux-test/clusters/my-cluster$ git push
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 16 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (5/5), 485 bytes | 485.00 KiB/s, done.
Total 5 (delta 0), reused 0 (delta 0)
To my-github-enterprise.com:my-github-organization/flux-test.git
   88b5146..a64aa66  master -> master
```

## Verify Deployment

```
/flux-test/clusters/my-cluster$ flux get kustomizations
NAME       	READY	MESSAGE                                                          	REVISION                                       	SUSPENDED
flux-system	True 	Applied revision: master/5a97ac633fda22efb22057e892c69242f2bbba9b	master/5a97ac633fda22efb22057e892c69242f2bbba9b	False
$ kubectl get pods
NAME         READY   STATUS    RESTARTS   AGE
alpine-ghe   1/1     Running   0          52s
```


## Errors

### failed to create repository

```
✗ failed to create repository, error: POST https://my-github-enterprise.com/api/v3/orgs/my-github-organization/repos: 401 Bad credentials []
```

===>

forgot to export TOKEN!

```
$ export GITHUB_TOKEN=<token>
$ export GITHUB_USER=gengwg
```

### ssh: handshake failed

```
$ flux bootstrap github   --hostname=my-github-enterprise.com   --ssh-hostname=my-github-enterprise.com   --owner=my-github-organization   --repository=flux-test   --branch=master   --path=clusters/my-cluster
► connecting to my-github-enterprise.com
✔ repository cloned
✚ generating manifests
✔ components manifests pushed
► generating sync manifests
✔ sync manifests pushed
► applying sync manifests
◎ waiting for cluster sync
✗ unable to clone 'ssh://git@my-github-enterprise.com/my-github-organization/flux-test', error: ssh: handshake failed: knownhosts: key is unknown
```

===>

Missed `--token-auth` option:

```
$ flux bootstrap github   --hostname=my-github-enterprise.com   --ssh-hostname=my-github-enterprise.com   --owner=my-github-organization   --repository=flux-test   --branch=master   --path=clusters/my-cluster --token-auth
```

