# Helm

A template is a form that has placeholders that an automated process will parse to replace them with values. Designed to perform a specific function, it marks the places where you must provide the specifics. 
An overlay is a set of replacement strings. Blocks of text in the original file are entirely replaced with new blocks of text.

    - A template needs to be carefully prepared to demand specific information in key places. When you use a template, you’re restricted to changing only those elements the template makes available.
    - An overlay doesn’t require the original file to be prepared in any way. You can replace any part in its entirety.


## Install Helm

https://helm.sh/docs/intro/install/

### MacOS

```
brew install helm
```

### Linux

```
wget https://get.helm.sh/helm-v3.3.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
tar -zvxf helm-v3.3.4-linux-amd64.tar.gz
```

## Commands 

creates a chart directory along with the common files and directories used in a chart:

```
helm create mychart
```

Install a chart from current directory:

```
$ helm install helloworld .
NAME: helloworld
LAST DEPLOYED: Wed Apr 21 11:39:14 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Uninstall chart from k8s:

```
helm delete mychart
```

### Add Repo

```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
```

### Uninstall chart release

```
helm list   # find the release name to delete
helm uninstall <release_name>
```

### Get a local copy of chart

```
helm fetch prometheus-community/prometheus --untar
```

### Prepare a template to install on k8s

```
helm template myprom prometheus-community/prometheus > k8s-myprom.yaml
kubectl apply -f k8s-myprom.yaml
```

### Install/uninstall chart into a specific namespace

```sh
$ kubectl create ns monitoring
$ helm install prometheus stable/prometheus-operator --namespace monitoring
# uninstall need namespace name specified
$ helm uninstall prometheus --namespace monitoring
release "prometheus" uninstalled
```

