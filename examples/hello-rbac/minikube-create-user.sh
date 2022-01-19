#!/bin/bash

if [[ -z "$1" ]] ;then
  echo "usage: $0 <username>"
  exit 1
fi

user=$1

kubectl create namespace ${user}
openssl genrsa -out ${user}.key 2048
openssl req -new -key ${user}.key -out ${user}.csr -subj "/CN=${user}/O=xyz"
export CA_LOCATION=~/.minikube/
openssl x509 -req -in ${user}.csr -CA $CA_LOCATION/ca.crt -CAkey $CA_LOCATION/ca.key -CAcreateserial -out ${user}.crt
kubectl config set-credentials ${user} --client-certificate=${user}.crt  --client-key=${user}.key
kubectl config set-context ${user}-context --cluster=minikube --namespace=${user} --user=${user}

# modify the yamls to use new user name then run:
#k create -f role-deployment-manager.yaml
#k create -f rolebinding-deployment-manager.yaml
