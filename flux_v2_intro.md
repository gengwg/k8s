This is an tutorial for using Flux with KIND cluster and Github on your laptop.

## Prerequisite


### Get Github personal access token

Get Github personal access token here. Check all permissions under repo.

https://github.com/settings/tokens

Export them:

```
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```

### Install the Flux CLI

```
brew install fluxcd/tap/flux
```

### Start KIND cluster

```
$ kind create cluster
```

### (Optional) bash auto completions

Put below in your `.bashrc` for flux bash auto completions:

```
$ . <(flux completion bash)
```

## Install Flux


Preflight check:

```
$ flux check --pre
► checking prerequisites
✔ kubectl 1.19.3 >=1.18.0-0
✔ Kubernetes 1.17.0 >=1.16.0-0
✔ prerequisites checks passed
```

Bootstrap github:

```
$ flux bootstrap github   --owner=$GITHUB_USER   --repository=fleet-infra   --branch=main   --path=./clusters/my-cluster   --personal
► connecting to github.com
✔ repository created
✔ repository cloned
✚ generating manifests
✔ components manifests pushed
► installing components in flux-system namespace
namespace/flux-system created
customresourcedefinition.apiextensions.k8s.io/alerts.notification.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/buckets.source.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/gitrepositories.source.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/helmcharts.source.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/helmreleases.helm.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/helmrepositories.source.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/kustomizations.kustomize.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/providers.notification.toolkit.fluxcd.io created
customresourcedefinition.apiextensions.k8s.io/receivers.notification.toolkit.fluxcd.io created
serviceaccount/helm-controller created
serviceaccount/kustomize-controller created
serviceaccount/notification-controller created
serviceaccount/source-controller created
clusterrole.rbac.authorization.k8s.io/crd-controller-flux-system created
clusterrolebinding.rbac.authorization.k8s.io/cluster-reconciler-flux-system created
clusterrolebinding.rbac.authorization.k8s.io/crd-controller-flux-system created
service/notification-controller created
service/source-controller created
service/webhook-receiver created
deployment.apps/helm-controller created
deployment.apps/kustomize-controller created
deployment.apps/notification-controller created
deployment.apps/source-controller created
networkpolicy.networking.k8s.io/allow-scraping created
networkpolicy.networking.k8s.io/allow-webhooks created
networkpolicy.networking.k8s.io/deny-ingress created
◎ verifying installation
✔ notification-controller: deployment ready
✔ source-controller: deployment ready
✔ kustomize-controller: deployment ready
✔ helm-controller: deployment ready
✔ install completed
► configuring deploy key
✔ deploy key configured
► generating sync manifests
✔ sync manifests pushed
► applying sync manifests
◎ waiting for cluster sync
✔ bootstrap finished
```

This creates new repo:

https://github.com/gengwg/fleet-infra/tree/main/clusters/my-cluster/flux-system

Some explainations:

* `--repository=fleet-infra`: repo it watches
* `--branch=main`: branch in that repo it watches
* `--path=./clusters/my-cluster`: path in that repo it watches recursively. any directory, files change will trigger


Check it deployed the pods for flux:

```
$ kubectl get pod -n flux-system
NAME                                      READY   STATUS    RESTARTS   AGE
helm-controller-5b47dc86b8-4pqtq          1/1     Running   0          3m45s
kustomize-controller-597d5c5487-hsgtn     1/1     Running   0          3m45s
notification-controller-9cf8fc669-b4r4d   1/1     Running   0          3m45s
source-controller-6bb76fdf5f-x56bp        1/1     Running   0          3m45s
```


## Example 1: Deploy an remote application from Github

### Clone the repo

```
$ git clone git@github.com:gengwg/fleet-infra.git
Cloning into 'fleet-infra'...
X11 forwarding request failed on channel 0
remote: Enumerating objects: 16, done.
remote: Counting objects: 100% (16/16), done.
remote: Compressing objects: 100% (9/9), done.
remote: Total 16 (delta 0), reused 13 (delta 0), pack-reused 0
Receiving objects: 100% (16/16), 15.92 KiB | 5.31 MiB/s, done.
$ cd fleet-infra/
```

### Create a podinfo github resource

```
vim ./clusters/my-cluster/podinfo-source.yaml

apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 30s
  ref:
    branch: master
  url: https://github.com/stefanprodan/podinfo
```

Commit and push it to the fleet-infra repository:

```
git add -A && git commit -m "Add podinfo GitRepository"
git push
```

### Create a Flux Kustomization manifest:

```
~/fleet-infra$ vim ./clusters/my-cluster/podinfo-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 5m0s
  path: ./kustomize
  prune: true
  sourceRef:
    kind: GitRepository
    name: podinfo
  validation: client
```

Commit and push:

```
~/fleet-infra$ git add -A && git commit -m "Add podinfo Kustomization"
[main cf60a00] Add podinfo Kustomization
 1 file changed, 14 insertions(+)
 create mode 100644 clusters/my-cluster/podinfo-kustomization.yaml
$ git push
X11 forwarding request failed on channel 0
Enumerating objects: 8, done.
Counting objects: 100% (8/8), done.
Delta compression using up to 4 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (5/5), 644 bytes | 644.00 KiB/s, done.
Total 5 (delta 0), reused 0 (delta 0), pack-reused 0
treTo github.com:gengwg/fleet-infra.git
   047331c..cf60a00  main -> main
```

The structure of your repository should look like this:

```
~/fleet-infra$ tree
.
├── clusters
│   └── my-cluster
│       ├── flux-system
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       ├── podinfo-kustomization.yaml
│       └── podinfo-source.yaml
└── README.md

3 directories, 6 files
```

### Verify Deployment

Check the Flux sync:

```
$ watch flux get kustomizations
$ flux get kustomizations
NAME       	READY	MESSAGE                                                          	REVISION                                       	SUSPENDED
flux-system	True 	Applied revision: main/cf60a001b51ea1a6b8089dac8689f85a5b5c19d7  	main/cf60a001b51ea1a6b8089dac8689f85a5b5c19d7  	False
podinfo    	True 	Applied revision: master/ef98a040c89180a4f39c0ab01dac47e6c3fced08	master/ef98a040c89180a4f39c0ab01dac47e6c3fced08	False
```

You can see it synced after a short time.


check that podinfo has been deployed on your cluster:

```
$ kubectl -n default get deployments,services
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/podinfo   2/2     2            2           2m56s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP             132m
service/podinfo      ClusterIP   10.96.88.143   <none>        9898/TCP,9999/TCP   2m56s
```

## Example 2: Deploy a local resource from yaml

Create a new dir:

```
$ mkdir flux-test
$ cd flux-test
```

### Create a local pod  resource

```
$ vim alpine-pod.yaml

apiVersion: v1
kind: Pod
metadata:
  name: alpine
  namespace: default
spec:
  containers:
  - image: alpine:3.2
    command:
      - /bin/sh
      - "-c"
      - "sleep 60m"
    imagePullPolicy: IfNotPresent
    name: alpine
  restartPolicy: Always
```

### Create a Kustomization manifest

```
$ cat kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: alpine
  namespace: default
resources:
  - alpine-pod.yaml
```

Push to Github:

```
$ git add flux-test/
$ git commit -m 'flux test'
$ git push
```

### Verify Deployment

```
# make sure no flux sync errors
gengwg@gengwg-mbp:~$ flux get kustomizations
NAME       	READY	MESSAGE                                                          	REVISION                                       	SUSPENDED
flux-system	True 	Applied revision: main/ce3aa51a55aec0cde3f370a38cfb7436c6830a4e  	main/ce3aa51a55aec0cde3f370a38cfb7436c6830a4e  	False
podinfo    	True 	Applied revision: master/ef98a040c89180a4f39c0ab01dac47e6c3fced08	master/ef98a040c89180a4f39c0ab01dac47e6c3fced08	False
# verify pod is deployed
gengwg@gengwg-mbp:~$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
alpine                    1/1     Running   0          38m  <----
podinfo-b44994dc4-gf25z   1/1     Running   0          104m
podinfo-b44994dc4-xsbpj   1/1     Running   0          104m
```

## Errors

Here are a few errors I met.

### Brew Error

```
gengwg@gengwg-mbp:~/fb$ brew install fluxcd/tap/flux
Error:
  homebrew-cask is a shallow clone.
To `brew update`, first run:
  git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask fetch --unshallow
This command may take a few minutes to run due to the large size of the repository.
This restriction has been made on GitHub's request because updating shallow
clones is an extremely expensive operation due to the tree layout and traffic of
Homebrew/homebrew-core and Homebrew/homebrew-cask. We don't do this for you
automatically to avoid repeatedly performing an expensive unshallow operation in
CI systems (which should instead be fixed to not use shallow clones). Sorry for
the inconvenience!
==> Installing flux from fluxcd/tap
==> Downloading https://github.com/fluxcd/flux2/releases/download/v0.10.0/flux_0.10.0_darwin_amd64.tar.gz
==> Downloading from https://github-releases.githubusercontent.com/258469100/2f48c400-87f4-11eb-9037-8d6206af14d7?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210323%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210323T184323Z&X-Amz-Expires=300&X-Amz-
######################################################################## 100.0%
Error: Your CLT does not support macOS 11.
It is either outdated or was modified.
Please update your CLT or delete it if no updates are available.
Update them from Software Update in System Preferences or run:
  softwareupdate --all --install --force

If that doesn't show you an update run:
  sudo rm -rf /Library/Developer/CommandLineTools
  sudo xcode-select --install

Alternatively, manually download them from:
  https://developer.apple.com/download/more/.

Error: An exception occurred within a child process:
  SystemExit: exit

$ softwareupdate --all --install --force
Software Update Tool

Finding available software
No updates are available.
```

===>

Reinstall xcode:

```
$ sudo rm -rf /Library/Developer/CommandLineTools
$ sudo xcode-select --install
$ brew install fluxcd/tap/flux
```

### Failed to read kustomization file

```
$ flux get kustomizations
NAME       	READY	MESSAGE                                                                                                                                                                                                                                                                                        	REVISION                                       	SUSPENDED
flux-system	False	kustomize build failed: accumulating resources: 2 errors occurred:                                                                                                                                                                                                                             	main/cf60a001b51ea1a6b8089dac8689f85a5b5c19d7  	False
           	     		* accumulateFile error: "accumulating resources from './flux-test': read /tmp/flux-system390372154/clusters/my-cluster/flux-test: is a directory"
           	     		* accumulateDirector error: "couldn't make target for path '/tmp/flux-system390372154/clusters/my-cluster/flux-test': Failed to read kustomization file under /tmp/flux-system390372154/clusters/my-cluster/flux-test:\napiVersion for Kustomization should be kustomize.config.k8s.io/v1beta1"


podinfo    	True 	Applied revision: master/ef98a040c89180a4f39c0ab01dac47e6c3fced08                                                                                                                                                                                                                              	master/ef98a040c89180a4f39c0ab01dac47e6c3fced08	False
```

===>

Api Version is incorrect:

```
apiVersion: kustomize.config.k8s.io/v1beta1
# apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
```

After that it should be fine:

```
$ flux get kustomizations
NAME       	READY	MESSAGE                                                          	REVISION                                       	SUSPENDED
flux-system	True 	Applied revision: main/ce3aa51a55aec0cde3f370a38cfb7436c6830a4e  	main/ce3aa51a55aec0cde3f370a38cfb7436c6830a4e  	False
podinfo    	True 	Applied revision: master/ef98a040c89180a4f39c0ab01dac47e6c3fced08	master/ef98a040c89180a4f39c0ab01dac47e6c3fced08	False
```
