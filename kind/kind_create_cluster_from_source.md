# Purpose

This is mainly for test purpose. Say you want to test some latest greatest feature in v1.23.6, but the KIND team hasn't built those [versions](https://hub.docker.com/r/kindest/node/tags) yet.


# Steps

Following [here](https://github.com/kubernetes-sigs/kind) to create a cluster from Kubernetes source.


## Clone Kubernetes source

Clone [Kubernetes source](https://github.com/kubernetes/kubernetes) into `$(go env GOPATH)/src/k8s.io/kubernetes`


```
gengwg@gengwg-mbp:~$ go env GOPATH
/Users/gengwg/go

gengwg@gengwg-mbp:~/go$ ls
pkg
gengwg@gengwg-mbp:~/go$ g git@github.com:kubernetes/kubernetes.git
Cloning into 'kubernetes'...
Enter passphrase for key '/Users/gengwg/.ssh/id_rsa':
remote: Enumerating objects: 1324661, done.
remote: Counting objects: 100% (174/174), done.
remote: Compressing objects: 100% (113/113), done.
remote: Total 1324661 (delta 80), reused 61 (delta 61), pack-reused 1324487
Receiving objects: 100% (1324661/1324661), 834.92 MiB | 12.02 MiB/s, done.
Resolving deltas: 100% (954920/954920), done.
Updating files: 100% (23414/23414), done.
gengwg@gengwg-mbp:~/go$ du -sh kubernetes/
1.2G	kubernetes/
```

Check out the version you want to build:

```
gengwg@gengwg-mbp:~/go/kubernetes$ git checkout v1.23.6
Updating files: 100% (5947/5947), done.
Note: switching to 'v1.23.6'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at ad3338546da Release commit for Kubernetes v1.23.6
```

NOTE: The source must be in `src/k8s.io/`:

```
gengwg@gengwg-mbp:~/go$ mkdir -p src/k8s.io/
src
src/k8s.io
gengwg@gengwg-mbp:~/go$ mv kubernetes/ src/k8s.io/
```

Otherwise you get error:

```
gengwg@gengwg-mbp:~/go/kubernetes$ kind build node-image --image kindest/node:v1.23.6
ERROR: error building node image: error finding kuberoot: could not find k8s.io/kubernetes module source under GOPATH=/Users/gengwg/go: cannot find package "k8s.io/kubernetes" in any of:
	go/src/k8s.io/kubernetes (from $GOROOT)
	/Users/gengwg/go/src/k8s.io/kubernetes (from $GOPATH)
```

## Build node image 

```
gengwg@gengwg-mbp:~/go$ kind build node-image --image kindest/node:v1.23.6
Starting to build Kubernetes
+++ [0420 22:24:32] Verifying Prerequisites....
+++ [0420 22:24:32] Using Docker for MacOS
+++ [0420 22:24:36] Building Docker image kube-build:build-da50957ed9-5-v1.23.0-go1.17.9-bullseye.0
+++ [0420 22:28:37] Creating data container kube-build-data-da50957ed9-5-v1.23.0-go1.17.9-bullseye.0
+++ [0420 22:28:42] Syncing sources to container
Object "-Version" is unknown, try "ip help".
+++ [0420 22:30:23] Running build command...
+++ [0420 22:30:34] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/prerelease-lifecycle-gen
Generating prerelease lifecycle code for 28 targets
+++ [0420 22:30:38] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/deepcopy-gen
Generating deepcopy code for 238 targets
+++ [0420 22:30:46] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/defaulter-gen
Generating defaulter code for 95 targets
+++ [0420 22:30:55] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/conversion-gen
Generating conversion code for 132 targets
+++ [0420 22:31:15] Building go targets for linux/amd64:
    ./vendor/k8s.io/kube-openapi/cmd/openapi-gen
Generating openapi code for KUBE
Generating openapi code for AGGREGATOR
Generating openapi code for APIEXTENSIONS
Generating openapi code for CODEGEN
Generating openapi code for SAMPLEAPISERVER
+++ [0420 22:31:41] Building go targets for linux/amd64:
    cmd/kube-apiserver
    cmd/kube-controller-manager
    cmd/kube-scheduler
    cmd/kube-proxy
    cmd/kubeadm
    cmd/kubectl
    cmd/kubelet
+++ [0420 22:36:48] Syncing out of container
Object "-Version" is unknown, try "ip help".
+++ [0420 22:37:03] Building images: linux-amd64
+++ [0420 22:37:04] Starting docker build for image: kube-apiserver-amd64
+++ [0420 22:37:04] Starting docker build for image: kube-controller-manager-amd64
+++ [0420 22:37:04] Starting docker build for image: kube-scheduler-amd64
+++ [0420 22:37:04] Starting docker build for image: kube-proxy-amd64
+++ [0420 22:37:14] Deleting docker image k8s.gcr.io/kube-scheduler-amd64:v1.23.6
+++ [0420 22:37:18] Deleting docker image k8s.gcr.io/kube-controller-manager-amd64:v1.23.6
+++ [0420 22:37:18] Deleting docker image k8s.gcr.io/kube-proxy-amd64:v1.23.6
+++ [0420 22:37:21] Deleting docker image k8s.gcr.io/kube-apiserver-amd64:v1.23.6
+++ [0420 22:37:22] Docker builds done
Finished building Kubernetes
Building node image ...
Building in kind-build-1650519446-722333682
sha256:eec0db91fef259a6dc21af8d0e547fed0836408549868cf04feab39b2b8b7860
Image build completed.
```

Verify it's been built:

```
gengwg@gengwg-mbp:~/go$ docker images | grep kind
kindest/node                                           v1.23.6                                          eec0db91fef2   2 minutes ago    1.64GB # <----
kindest/node                                           v1.23.5                                          b960beb7426e   3 weeks ago      941MB
kindest/node                                           <none>                                           6b76f7b7813a   6 weeks ago      1.47GB
kindest/base                                           v20220305-b67a383f                               816dc6345e34   6 weeks ago      281MB
kindest/node                                           v1.21.1                                          65d38077cb24   10 months ago    931MB
kindest/node                                           <none>                                           32b8b755dee8   11 months ago    1.12GB
```

## Create the cluster

Now we can create a cluster with that version we just built:

```
gengwg@gengwg-mbp:~$ kind create cluster --image kindest/node:v1.23.6
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.23.6) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Thanks for using kind! 😊

gengwg@gengwg-mbp:~$ k version --short=true
Client Version: v1.23.4
Server Version: v1.23.6 # <--------
```


# Possible issues

Possible some issues you may have. Here are how to fix some on MacOS.

## Upgrade bash

```
gengwg@gengwg-mbp:~/go$ kind build node-image --image kindest/node:v1.23.6
Starting to build Kubernetes
ERROR: This script requires a minimum bash version of 4.2, but got version of 3.2
On macOS with homebrew 'brew install bash' is sufficient.
make: *** [quick-release-images] Error 1
Failed to build Kubernetes: failed to build images: command "make quick-release-images 'KUBE_EXTRA_WHAT=cmd/kubeadm cmd/kubectl cmd/kubelet' KUBE_VERBOSE=0 KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PLATFORMS=linux/amd64" failed with error: exit status 2
ERROR: error building node image: failed to build kubernetes: failed to build images: command "make quick-release-images 'KUBE_EXTRA_WHAT=cmd/kubeadm cmd/kubectl cmd/kubelet' KUBE_VERBOSE=0 KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PLATFORMS=linux/amd64" failed with error: exit status 2
Command Output: ERROR: This script requires a minimum bash version of 4.2, but got version of 3.2
On macOS with homebrew 'brew install bash' is sufficient.
make: *** [quick-release-images] Error 1

gengwg@gengwg-mbp:~/go$ brew install bash

gengwg@gengwg-mbp:~/go$ bash --version
GNU bash, version 5.1.16(1)-release (x86_64-apple-darwin21.1.0)
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

## Install gnu-tar

```
gengwg@gengwg-mbp:~/go$ kind build node-image --image kindest/node:v1.23.6
Starting to build Kubernetes
+++ [0420 22:23:13] Verifying Prerequisites....
  !!! Cannot find GNU tar. Build on Linux or install GNU tar
      on Mac OS X (brew install gnu-tar).
make: *** [quick-release-images] Error 1
Failed to build Kubernetes: failed to build images: command "make quick-release-images 'KUBE_EXTRA_WHAT=cmd/kubeadm cmd/kubectl cmd/kubelet' KUBE_VERBOSE=0 KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PLATFORMS=linux/amd64" failed with error: exit status 2
ERROR: error building node image: failed to build kubernetes: failed to build images: command "make quick-release-images 'KUBE_EXTRA_WHAT=cmd/kubeadm cmd/kubectl cmd/kubelet' KUBE_VERBOSE=0 KUBE_BUILD_HYPERKUBE=n KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_PLATFORMS=linux/amd64" failed with error: exit status 2
Command Output: +++ [0420 22:23:13] Verifying Prerequisites....
  !!! Cannot find GNU tar. Build on Linux or install GNU tar
      on Mac OS X (brew install gnu-tar).
make: *** [quick-release-images] Error 1

gengwg@gengwg-mbp:~/go$ brew install gnu-tar
==> Downloading https://ghcr.io/v2/homebrew/core/gnu-tar/manifests/1.34_1
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/gnu-tar/blobs/sha256:dc04edcba6fb8c7df23e7a97eedb84a2ea9026b12e9c2a
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sha256:dc04edcba6fb8c7df23e7a97eedb84a
######################################################################## 100.0%
==> Pouring gnu-tar--1.34_1.monterey.bottle.tar.gz
==> Caveats
GNU "tar" has been installed as "gtar".
If you need to use it as "tar", you can add a "gnubin" directory
to your PATH from your bashrc like:

    PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
==> Summary
🍺  /usr/local/Cellar/gnu-tar/1.34_1: 15 files, 1.8MB
==> Running `brew cleanup gnu-tar`...
Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
```

## Prune image

```
#5 ERROR: failed to register layer: Error processing tar file(exit status 1): write /usr/local/go/pkg/linux_ppc64le/encoding/gob.a: no space left on device
------
 > [ 1/13] FROM k8s.gcr.io/build-image/kube-cross:v1.22.0-go1.16.15-buster.0@sha256:e675861e6d2637f8b41bf5de65981305d15f074e94382a69c7366aa5336315d4:
------
error: failed to solve: failed to register layer: Error processing tar file(exit status 1): write /usr/local/go/pkg/linux_ppc64le/encoding/gob.a: no space left on device

To retry manually, run:

DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --load -t kube-build:build-da50957ed9-5-v1.22.0-go1.16.15-buster.0 --pull=false --build-arg=KUBE_BUILD_IMAGE_CROSS_TAG=v1.22.0-go1.16.15-buster.0 --build-arg=KUBE_BASE_IMAGE_REGISTRY=k8s.gcr.io/build-image /Users/gengwg/go/src/k8s.io/kubernetes/_output/images/kube-build:build-da50957ed9-5-v1.22.0-go1.16.15-buster.0

!!! [0420 22:54:34] Call tree:
!!! [0420 22:54:34]  1: build/release-images.sh:39 kube::build::build_image(...)
make: *** [quick-release-images] Error 1

gengwg@gengwg-mbp:~/go/src/k8s.io/kubernetes$ docker image prune
....
Total reclaimed space: 12.5GB
```

# Another example

Here is another example for building v1.22.9:

```
# v1.22.9

gengwg@gengwg-mbp:~$ cd go/src/k8s.io/kubernetes/
gengwg@gengwg-mbp:~/go/src/k8s.io/kubernetes$ git checkout v1.22.9
Updating files: 100% (6336/6336), done.
Previous HEAD position was ad3338546da Release commit for Kubernetes v1.23.6
HEAD is now at 6df4433e288 Release commit for Kubernetes v1.22.9

gengwg@gengwg-mbp:~/go/src/k8s.io/kubernetes$ kind build node-image --image kindest/node:v1.22.9
Starting to build Kubernetes
+++ [0420 22:56:36] Verifying Prerequisites....
+++ [0420 22:56:36] Using Docker for MacOS
+++ [0420 22:56:38] Building Docker image kube-build:build-da50957ed9-5-v1.22.0-go1.16.15-buster.0
+++ [0420 22:58:50] Creating data container kube-build-data-da50957ed9-5-v1.22.0-go1.16.15-buster.0
+++ [0420 22:58:55] Syncing sources to container
Object "-Version" is unknown, try "ip help".
+++ [0420 22:59:53] Running build command...
+++ [0420 23:00:02] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/prerelease-lifecycle-gen
Generating prerelease lifecycle code for 27 targets
+++ [0420 23:00:06] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/deepcopy-gen
Generating deepcopy code for 234 targets
+++ [0420 23:00:12] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/defaulter-gen
Generating defaulter code for 93 targets
+++ [0420 23:00:20] Building go targets for linux/amd64:
    ./vendor/k8s.io/code-generator/cmd/conversion-gen
Generating conversion code for 128 targets
+++ [0420 23:00:35] Building go targets for linux/amd64:
    ./vendor/k8s.io/kube-openapi/cmd/openapi-gen
Generating openapi code for KUBE
Generating openapi code for AGGREGATOR
Generating openapi code for APIEXTENSIONS
Generating openapi code for CODEGEN
Generating openapi code for SAMPLEAPISERVER
+++ [0420 23:00:45] Building go targets for linux/amd64:
    cmd/kube-apiserver
    cmd/kube-controller-manager
    cmd/kube-scheduler
    cmd/kube-proxy
    cmd/kubeadm
    cmd/kubectl
    cmd/kubelet
+++ [0420 23:04:45] Syncing out of container
Object "-Version" is unknown, try "ip help".
+++ [0420 23:05:00] Building images: linux-amd64
+++ [0420 23:05:01] Starting docker build for image: kube-apiserver-amd64
+++ [0420 23:05:01] Starting docker build for image: kube-controller-manager-amd64
+++ [0420 23:05:01] Starting docker build for image: kube-scheduler-amd64
+++ [0420 23:05:01] Starting docker build for image: kube-proxy-amd64
+++ [0420 23:05:09] Deleting docker image k8s.gcr.io/kube-scheduler-amd64:v1.22.9
+++ [0420 23:05:13] Deleting docker image k8s.gcr.io/kube-proxy-amd64:v1.22.9
+++ [0420 23:05:13] Deleting docker image k8s.gcr.io/kube-controller-manager-amd64:v1.22.9
+++ [0420 23:05:16] Deleting docker image k8s.gcr.io/kube-apiserver-amd64:v1.22.9
+++ [0420 23:05:16] Docker builds done
Finished building Kubernetes
Building node image ...
Building in kind-build-1650521119-1371439494
sha256:6b34bb1946cd71efd88c756d1e1e93bc444e113175922aadaf52bf2fdb8beea1
Image build completed.

gengwg@gengwg-mbp:~/go/src/k8s.io/kubernetes$ docker image ls | grep v1.22.9
kindest/node                                           v1.22.9                                          6b34bb1946cd   11 seconds ago   1.33GB

gengwg@gengwg-mbp:~$ kind delete cluster
Deleting cluster "kind" ...
gengwg@gengwg-mbp:~$ kind create cluster --image kindest/node:v1.22.9
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.22.9) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
```
