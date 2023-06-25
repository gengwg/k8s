## Install

M1:

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
$ minikube version
minikube version: v1.30.1
commit: 08896fd1dc362c097c925146c4a0d0dac715ace0
```

Intel:

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

## Usage

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
minikube addons enable ingress

```
