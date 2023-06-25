# Tutorial: Installing Harbor on Minikube

In this tutorial, we will guide you through the process of installing Harbor, an open-source container registry, on Minikube, a local Kubernetes cluster. Harbor provides features such as image management, vulnerability scanning, and replication. By following the steps below, you'll be able to set up Harbor on your Minikube cluster and access its web portal.

## Prerequisites

Before you begin, make sure you have the following prerequisites installed:

- Minikube: A local Kubernetes cluster. You can install Minikube by following the official documentation for your operating system.
- Helm: The package manager for Kubernetes. You can install Helm by following the official documentation for your operating system.

## Step 1: Start Minikube

Start Minikube using the following command:

```shell
$ minikube start
```

Example:

```
$ minikube  start
😄  minikube v1.28.0 on Fedora 36
🎉  minikube 1.30.1 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.30.1
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.25.3 on Docker 20.10.20 ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner

❗  /usr/local/bin/kubectl is version 1.20.0, which may have incompatibilities with Kubernetes 1.25.3.
    ▪ Want kubectl v1.25.3? Try 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

## Step 2: Add the Harbor Helm repository

Add the Harbor Helm repository by running the following command:

```shell
$ helm repo add harbor https://helm.goharbor.io
```

## Step 3: Fetch the Harbor Helm chart

Fetch the Harbor Helm chart using the following command:

```shell
$ helm fetch harbor/harbor --untar
```

This command will download the Harbor Helm chart and extract its contents.

## Step 4: Install Harbor

Change to the Harbor chart directory using the following command:

```shell
$ cd harbor/
```

Install Harbor by running the following Helm command:

```shell
$ helm install myhbr .
```

Example:

```
$ helm install myhbr .
NAME: myhbr
LAST DEPLOYED: Sat Jun 24 17:33:57 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Please wait for several minutes for Harbor deployment to complete.
Then you should be able to visit the Harbor portal at https://core.harbor.domain
For more details, please visit https://github.com/goharbor/harbor
```

## Step 5: Wait for Harbor deployment to complete

After running the Helm install command, you need to wait for the Harbor deployment to complete. You can check the deployment status by running the following command:

```shell
$ kubectl get pods -w
```

Wait until all the Harbor pods are in the "Running" state. This may take a few minutes.

```
$ k get po -w
NAME                                          READY   STATUS              RESTARTS       AGE
keycloak-5ff4bd964b-b66cv                     1/1     Running             1 (3m9s ago)   191d
myhbr-harbor-core-7f86c94c9b-44fq8            1/1     Running             0              108s
myhbr-harbor-database-0                       1/1     Running             0              108s
myhbr-harbor-jobservice-8f8fb565-4kfrq        0/1     Running             0              109s
myhbr-harbor-notary-server-54857b7dd6-k85h8   1/1     Running             0              109s
myhbr-harbor-notary-signer-844d8895bc-7gxvr   1/1     Running             0              109s
myhbr-harbor-portal-867579dc89-vctj4          1/1     Running             0              109s
myhbr-harbor-redis-0                          1/1     Running             0              109s
myhbr-harbor-registry-5dbd695fd4-lftgc        0/2     ContainerCreating   0              109s
myhbr-harbor-trivy-0                          1/1     Running             0              108s
myhbr-harbor-registry-5dbd695fd4-lftgc        0/2     Running             0              117s
myhbr-harbor-registry-5dbd695fd4-lftgc        1/2     Running             0              118s
myhbr-harbor-registry-5dbd695fd4-lftgc        2/2     Running             0              118s
myhbr-harbor-jobservice-8f8fb565-4kfrq        1/1     Running             0              2m7s
```

## Step 6: Enable Ingress addon

Enable the Ingress addon on Minikube by running the following command:

```shell
$ minikube addons enable ingress
```

This command will enable the Ingress controller on your Minikube cluster, which allows external access to services.

## Step 7: Update /etc/hosts file

To access the Harbor web portal, you need to update your `/etc/hosts` file with the IP address of your Minikube cluster. Open the `/etc/hosts` file using a text editor of your choice with root privileges. For example:

```shell
$ sudo vim /etc/hosts
```

Add the following lines to the file:

```
<Minikube_IP>  core.harbor.domain
<Minikube_IP>  notary.harbor.domain
```

Replace `<Minikube_IP>` with the IP address of your Minikube cluster. Save and close the file.

Get your minikube iP by:

```
$ minikube ip
192.168.49.2
```

## Step 8: Access the Harbor web portal

You can now access the Harbor web portal by visiting `https://core.harbor.domain/` in your web browser. 

> **Note:** The self-signed SSL certificate used by Harbor may trigger a security warning in your web browser. You can proceed and accept the warning to access the web portal.
