# Tutorial: Horizontal Pod Autoscaling (HPA) in Kubernetes

In this tutorial, you will learn how to use Horizontal Pod Autoscaling (HPA) in Kubernetes. HPA allows you to automatically scale the number of pods in a deployment based on certain metrics, such as CPU utilization. This ensures that your application can handle increased traffic and demand without manual intervention.

# Prerequisites

Before you begin, ensure that you have the following:

- Kubernetes cluster up and running
- Metrics server up and running
- `kubectl` command-line tool installed and configured to connect to your cluster

# Steps

## Step 1: Deploy an Application

First, we need to deploy an application to demonstrate HPA. Create a file named `php-apache.yaml` with the following contents:

```yaml
$ cat php-apache.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        #image: registry.k8s.io/hpa-example
        image: harbor.my.com/gengwg/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
```

Save the file and apply the configuration to your cluster using the following command:

```bash
$ k apply -f php-apache.yaml
deployment.apps/php-apache created
service/php-apache created
```

This will create a deployment with a single pod running a PHP Apache server.

## Step 2: Verify Deployment

To verify that the deployment is running, execute the following command:

```bash
kubectl get pods
```

You should see an output similar to the following:

```
NAME                         READY   STATUS    RESTARTS   AGE
php-apache-xxxxxxxxx-xxxxx   1/1     Running   0          xxm
```

Example output:

```
$ k get -f php-apache.yaml
NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/php-apache   0/1     1            0           5s

NAME                 TYPE        CLUSTER-IP                  EXTERNAL-IP   PORT(S)   AGE
service/php-apache   ClusterIP   fdf5:6da1:fe0d:cc1e::cd1f   <none>        80/TCP    5s

$ k get po | grep php
php-apache-65dc947646-6h4rl        1/1     Running                    0          4s
```


Make sure that the pod is in the "Running" state.

## Step 3: Configure Horizontal Pod Autoscaling

Now, let's configure HPA for the `php-apache` deployment. Run the following command:

```bash
$ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
horizontalpodautoscaler.autoscaling/php-apache autoscaled
```

This command sets up HPA for the `php-apache` deployment with the following parameters:
- `--cpu-percent=50`: The target CPU utilization percentage at which to scale the deployment.
- `--min=1`: The minimum number of pods the deployment should have.
- `--max=10`: The maximum number of pods the deployment can scale up to.

## Step 4: Check HPA Status

To check the status of HPA, execute the following command:

```bash
kubectl get hpa
```

You should see an output similar to the following:

```
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   0%/50%    1         10        1          xxs
```

The `TARGETS` column shows the current CPU utilization percentage and the target percentage for scaling.

## Step 5: Generate Load

To trigger the scaling of the deployment, we need to generate some load on the application. Run the following command to create a load generator pod:

```bash
$ kubectl run -i --tty load-generator --rm --image=harbor.my.com/gengwg/busybox:1.35.0 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

This command creates a temporary pod that generates continuous requests to the php-apache service.

## Step 6: Monitor Autoscaling

To monitor the autoscaling behavior, run the following command:

```shell
$ kubectl get hpa php-apache --watch
```

You will see the current state of the HPA, including the target CPU utilization, the minimum and maximum number of pods, and the current number of replicas. As the load increases, you should observe the HPA scaling up the number of pods to handle the increased demand.

```
$ kubectl get hpa php-apache --watch
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   0%/50%    1         10        1          40s
php-apache   Deployment/php-apache   1%/50%    1         10        1          2m
php-apache   Deployment/php-apache   250%/50%   1         10        1          2m30s
php-apache   Deployment/php-apache   250%/50%   1         10        4          2m45s
php-apache   Deployment/php-apache   250%/50%   1         10        5          3m
php-apache   Deployment/php-apache   122%/50%   1         10        5          3m15s
php-apache   Deployment/php-apache   87%/50%    1         10        5          3m30s
php-apache   Deployment/php-apache   61%/50%    1         10        5          3m45s
php-apache   Deployment/php-apache   59%/50%    1         10        7          4m
php-apache   Deployment/php-apache   63%/50%    1         10        7          4m15s
php-apache   Deployment/php-apache   58%/50%    1         10        7          4m30s
```

You can also observe the replica for the deplopyment increasing:

```
$ k get deploy php-apache
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
php-apache   5/5     5            5           4m33s
$ k get po | grep php
php-apache-65dc947646-4t7cf        0/1     ContainerCreating          0          3s
php-apache-65dc947646-69qhj        1/1     Running                    0          78s
php-apache-65dc947646-6h4rl        1/1     Running                    0          4m43s
php-apache-65dc947646-ckmv9        1/1     Running                    0          63s
php-apache-65dc947646-hh8t4        1/1     Running                    0          78s
php-apache-65dc947646-p42vn        1/1     Running                    0          78s
php-apache-65dc947646-x76hf        0/1     ContainerCreating          0          3s


$ k get deploy php-apache
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
php-apache   7/7     7            7           5m42s
$ k get po | grep php
php-apache-65dc947646-4t7cf        1/1     Running                    0          65s
php-apache-65dc947646-69qhj        1/1     Running                    0          2m20s
php-apache-65dc947646-6h4rl        1/1     Running                    0          5m45s
php-apache-65dc947646-ckmv9        1/1     Running                    0          2m5s
php-apache-65dc947646-hh8t4        1/1     Running                    0          2m20s
php-apache-65dc947646-p42vn        1/1     Running                    0          2m20s
php-apache-65dc947646-x76hf        1/1     Running                    0          65s
$ k tree deploy php-apache
NAMESPACE  NAME                                 READY  REASON  AGE
gengwg     Deployment/php-apache                -              5m13s
gengwg     └─ReplicaSet/php-apache-65dc947646   -              5m13s
gengwg       ├─Pod/php-apache-65dc947646-4t7cf  True           33s
gengwg       ├─Pod/php-apache-65dc947646-69qhj  True           108s
gengwg       ├─Pod/php-apache-65dc947646-6h4rl  True           5m13s
gengwg       ├─Pod/php-apache-65dc947646-ckmv9  True           93s
gengwg       ├─Pod/php-apache-65dc947646-hh8t4  True           108s
gengwg       ├─Pod/php-apache-65dc947646-p42vn  True           108s
gengwg       └─Pod/php-apache-65dc947646-x76hf  True           33s
```

You can also check the HPA status:

```
$ k get hpa php-apache -o yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  annotations:
    autoscaling.alpha.kubernetes.io/conditions: '[{"type":"AbleToScale","status":"True","lastTransitionTime":"2023-06-19T23:17:20Z","reason":"ReadyForNewScale","message":"recommended
      size matches current size"},{"type":"ScalingActive","status":"True","lastTransitionTime":"2023-06-19T23:17:20Z","reason":"ValidMetricFound","message":"the
      HPA was able to successfully calculate a replica count from cpu resource utilization
      (percentage of request)"},{"type":"ScalingLimited","status":"False","lastTransitionTime":"2023-06-19T23:19:50Z","reason":"DesiredWithinRange","message":"the
      desired count is within the acceptable range"}]'
    autoscaling.alpha.kubernetes.io/current-metrics: '[{"type":"Resource","resource":{"name":"cpu","currentAverageUtilization":44,"currentAverageValue":"89m"}}]'
  creationTimestamp: "2023-06-19T23:17:05Z"
  name: php-apache
  namespace: gengwg
  resourceVersion: "636650786"
  uid: 007be2b0-1d8a-433b-9f2f-13a5f0bab48e
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  targetCPUUtilizationPercentage: 50
status:
  currentCPUUtilizationPercentage: 44
  currentReplicas: 7
  desiredReplicas: 7
  lastScaleTime: "2023-06-19T23:20:50Z"
```

View the events:

```
$ k describe hpa php-apache
Name:                                                  php-apache
Namespace:                                             gengwg
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Mon, 19 Jun 2023 16:17:05 -0700
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  72% (144m) / 50%
Min replicas:                                          1
Max replicas:                                          10
Deployment pods:                                       7 current / 7 desired
Conditions:
  Type            Status  Reason              Message
  ----            ------  ------              -------
  AbleToScale     True    ReadyForNewScale    recommended size matches current size
  ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
  ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
Events:
  Type    Reason             Age                From                       Message
  ----    ------             ----               ----                       -------
  Normal  SuccessfulRescale  79s (x2 over 71m)  horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  19s (x2 over 70m)  horizontal-pod-autoscaler  New size: 7; reason: cpu resource utilization (percentage of request) above target

$ k describe deploy php-apache
....

Events:
  Type    Reason             Age                 From                   Message
  ----    ------             ----                ----                   -------
  Normal  ScalingReplicaSet  39m (x2 over 109m)  deployment-controller  Scaled up replica set php-apache-65dc947646 to 4
  Normal  ScalingReplicaSet  38m (x2 over 108m)  deployment-controller  Scaled up replica set php-apache-65dc947646 to 7
  Normal  ScalingReplicaSet  31m                 deployment-controller  Scaled down replica set php-apache-65dc947646 to 4
  Normal  ScalingReplicaSet  31m (x2 over 100m)  deployment-controller  Scaled down replica set php-apache-65dc947646 to 1
```

## Step 7: Stop the load


Stop the load. Observe the replicas going down.

```
$ kubectl run -i --tty load-generator --rm --image=harbor.my.com/gengwg/busybox:1.35.0 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
If you don't see a command prompt, try pressing enter.
OK!OK!OK!OK!^C
E0619 16:22:54.957208 3704281 v2.go:105] EOF
pod "load-generator" deleted
pod gengwg/load-generator terminated (Error)
```

NOTE: Autoscaling the replicas may take a few minutes.

```
$ kubectl get hpa php-apache --watch
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   0%/50%    1         10        1          40s
php-apache   Deployment/php-apache   1%/50%    1         10        1          2m
php-apache   Deployment/php-apache   250%/50%   1         10        1          2m30s
php-apache   Deployment/php-apache   250%/50%   1         10        4          2m45s
php-apache   Deployment/php-apache   250%/50%   1         10        5          3m
php-apache   Deployment/php-apache   122%/50%   1         10        5          3m15s
php-apache   Deployment/php-apache   87%/50%    1         10        5          3m30s
php-apache   Deployment/php-apache   61%/50%    1         10        5          3m45s
php-apache   Deployment/php-apache   59%/50%    1         10        7          4m
php-apache   Deployment/php-apache   63%/50%    1         10        7          4m15s
php-apache   Deployment/php-apache   58%/50%    1         10        7          4m30s
php-apache   Deployment/php-apache   44%/50%    1         10        7          4m45s
php-apache   Deployment/php-apache   46%/50%    1         10        7          5m
php-apache   Deployment/php-apache   47%/50%    1         10        7          5m15s
php-apache   Deployment/php-apache   50%/50%    1         10        7          5m30s
php-apache   Deployment/php-apache   47%/50%    1         10        7          5m45s
php-apache   Deployment/php-apache   45%/50%    1         10        7          6m
php-apache   Deployment/php-apache   44%/50%    1         10        7          6m15s
php-apache   Deployment/php-apache   21%/50%    1         10        7          6m30s
php-apache   Deployment/php-apache   2%/50%     1         10        7          6m45s
php-apache   Deployment/php-apache   0%/50%     1         10        7          7m1s
php-apache   Deployment/php-apache   0%/50%     1         10        7          11m
php-apache   Deployment/php-apache   0%/50%     1         10        3          11m
php-apache   Deployment/php-apache   0%/50%     1         10        1          11m
```

You can also see the deployment replica back to 1.

```
$ k get deploy php-apache -w
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
php-apache   7/7     7            7           10m
php-apache   7/3     7            7           12m
php-apache   7/3     7            7           12m
php-apache   3/3     3            3           12m
php-apache   3/1     3            3           12m
php-apache   3/1     3            3           12m
php-apache   1/1     1            1           12m
```


Congratulations! You have successfully set up Horizontal Pod Autoscaling (HPA) in Kubernetes. You have learned how to deploy an application, configure HPA, and test the autoscaling behavior. Autoscaling allows your application to dynamically adapt to varying levels of traffic, ensuring optimal performance and resource utilization.


# Next Steps

## [Autoscaling on multiple metrics and custom metrics](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics)

HPA can also scale based on multiple metrics and custom metrics. You can specify additional metrics like memory utilization, requests per second, or any custom metric that you expose.

To scale on custom metrics, you will need to have a metrics server and custom metrics adapter set up in your cluster. The configuration and usage of these components go beyond the scope of this tutorial, but you can find detailed documentation and examples in the Kubernetes official documentation.
