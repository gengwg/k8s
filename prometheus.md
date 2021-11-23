## Install on local dev

Add helm repo and install:

```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm install hello-prom prometheus-community/kube-prometheus-stack
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /Users/gengwg/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /Users/gengwg/.kube/config
W1123 09:14:55.292369   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:55.298112   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:55.303671   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:55.307941   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:55.311523   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:55.315010   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:55.318315   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:56.303338   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:14:56.809723   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.036822   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.099669   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.100120   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.103001   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.104449   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.104464   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.106605   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:03.109111   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:04.578341   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:05.110277   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1123 09:15:09.062879   48661 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
NAME: hello-prom
LAST DEPLOYED: Tue Nov 23 09:14:54 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=hello-prom"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

Verify installed:

```
gengwg@gengwg-mbp:~$ kubectl --namespace default get pods -l "release=hello-prom"
NAME                                                   READY   STATUS    RESTARTS   AGE
hello-prom-kube-prometheus-operator-85f9f77dfc-cv89q   1/1     Running   0          27s
hello-prom-prometheus-node-exporter-fjqlb              1/1     Running   0          27s
gengwg@gengwg-mbp:~$ kubectl get svc
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                     ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   2m19s
hello-prom-grafana                        ClusterIP   10.96.100.134   <none>        80/TCP                       2m28s
hello-prom-kube-prometheus-alertmanager   ClusterIP   10.96.62.103    <none>        9093/TCP                     2m28s
hello-prom-kube-prometheus-operator       ClusterIP   10.96.178.66    <none>        443/TCP                      2m28s
hello-prom-kube-prometheus-prometheus     ClusterIP   10.96.171.150   <none>        9090/TCP                     2m28s
hello-prom-kube-state-metrics             ClusterIP   10.96.75.197    <none>        8080/TCP                     2m28s
hello-prom-prometheus-node-exporter       ClusterIP   10.96.154.41    <none>        9100/TCP                     2m28s
kubernetes                                ClusterIP   10.96.0.1       <none>        443/TCP                      17h
prometheus-operated                       ClusterIP   None            <none>        9090/TCP                     2m18s
```

### Access Prometheus UI

```
gengwg@gengwg-mbp:~$ kubectl port-forward service/hello-prom-kube-prometheus-prometheus 9090:9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```

Go to browser: 

http://localhost:9090/graph

### Access Grafana UI

```
gengwg@gengwg-mbp:~$ kubectl port-forward service/hello-prom-grafana 3000:80
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```

Go to browser: 

http://localhost:3000/

### Install into a namespace

All the same as above, just add `-n monitoring` to each command, i.e.:

```
$ kubectl create ns monitoring
$ helm install hello-prom prometheus-community/kube-prometheus-stack -n monitoring
$ kubectl --namespace monitoring get pods -l "release=hello-prom"
$ kubectl get svc -n monitoring
$ kubectl port-forward service/hello-prom-kube-prometheus-prometheus 9090:9090 -n monitoring
$ kubectl port-forward service/hello-prom-grafana 3000:80 -n monitoring
```
