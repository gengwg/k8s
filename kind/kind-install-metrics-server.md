```
$ helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

$ helm upgrade --install metrics-server -n kube-system  metrics-server/metrics-server  --set=args={--kubelet-insecure-tls}
Release "metrics-server" does not exist. Installing it now.
NAME: metrics-server
LAST DEPLOYED: Sat Apr 23 20:50:54 2022
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
***********************************************************************
* Metrics Server                                                      *
***********************************************************************
  Chart version: 3.8.2
  App version:   0.6.1
  Image tag:     k8s.gcr.io/metrics-server/metrics-server:v0.6.1
***********************************************************************

$ k top no
Error from server (ServiceUnavailable): the server is currently unable to handle the request (get nodes.metrics.k8s.io)\

# wait a few minutes

$ k logs metrics-server-6744b4c64f-cwgnw -n kube-system
I0424 03:50:56.032874       1 serving.go:342] Generated self-signed cert (/tmp/apiserver.crt, /tmp/apiserver.key)
I0424 03:50:56.750733       1 requestheader_controller.go:169] Starting RequestHeaderAuthRequestController
I0424 03:50:56.750767       1 shared_informer.go:240] Waiting for caches to sync for RequestHeaderAuthRequestController
I0424 03:50:56.751153       1 configmap_cafile_content.go:201] "Starting controller" name="client-ca::kube-system::extension-apiserver-authentication::client-ca-file"
I0424 03:50:56.751253       1 shared_informer.go:240] Waiting for caches to sync for client-ca::kube-system::extension-apiserver-authentication::client-ca-file
I0424 03:50:56.751894       1 configmap_cafile_content.go:201] "Starting controller" name="client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file"
I0424 03:50:56.751921       1 shared_informer.go:240] Waiting for caches to sync for client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file
I0424 03:50:56.753294       1 dynamic_serving_content.go:131] "Starting controller" name="serving-cert::/tmp/apiserver.crt::/tmp/apiserver.key"
I0424 03:50:56.753569       1 secure_serving.go:266] Serving securely on [::]:4443
I0424 03:50:56.753625       1 tlsconfig.go:240] "Starting DynamicServingCertificateController"
W0424 03:50:56.755024       1 shared_informer.go:372] The sharedIndexInformer has started, run more than once is not allowed
I0424 03:50:56.851790       1 shared_informer.go:247] Caches are synced for client-ca::kube-system::extension-apiserver-authentication::client-ca-file
I0424 03:50:56.851884       1 shared_informer.go:247] Caches are synced for RequestHeaderAuthRequestController
I0424 03:50:56.852041       1 shared_informer.go:247] Caches are synced for client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file

$ k top no
NAME                           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
kind-multi-nod-control-plane   316m         7%     948Mi           5%
kind-multi-nod-worker          59m          1%     216Mi           1%
kind-multi-nod-worker2         39m          0%     193Mi           1%

$ k top po -n kube-system --containers=true
POD                                                    NAME                      CPU(cores)   MEMORY(bytes)
coredns-558bd4d5db-9wf2b                               coredns                   8m           10Mi
coredns-558bd4d5db-td76k                               coredns                   8m           10Mi
etcd-kind-multi-nod-control-plane                      etcd                      33m          40Mi
kindnet-4cbhq                                          kindnet-cni               1m           6Mi
kindnet-df25z                                          kindnet-cni               1m           6Mi
kindnet-pgjxm                                          kindnet-cni               5m           6Mi
kube-apiserver-kind-multi-nod-control-plane            kube-apiserver            111m         338Mi
kube-controller-manager-kind-multi-nod-control-plane   kube-controller-manager   23m          52Mi
kube-proxy-5ph6f                                       kube-proxy                1m           11Mi
kube-proxy-jd6kv                                       kube-proxy                1m           11Mi
kube-proxy-qffn2                                       kube-proxy                1m           12Mi
kube-scheduler-kind-multi-nod-control-plane            kube-scheduler            7m           18Mi
metrics-server-6744b4c64f-cwgnw                        metrics-server            6m           14Mi
```
