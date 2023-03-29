# Enable static CPU Management Policy on the Node

## Steps 

1. Update kubelet config
  
Add these lines to `/var/lib/kubelet/kubelet-config.yaml`:

```
cpuManagerPolicy: "static"
kubeReserved:
  cpu: "1000m" # reserved cpu for kubelet itself. must have.
  memory: "1000Mi"  # reserved memory for kubelet. optional for cpu, but needed for memory.
topologyManagerPolicy: "best-effort"
```

2. Drain the node. 
  
```
$ k drain node0010  --ignore-daemonsets --delete-emptydir-data
```

3. Stop kubelet.

```
# systemctl stop kubelet
```

4. Remove the old CPU manager state file. 
  
```
# cd /var/lib/kubelet/
# mv cpu_manager_state cpu_manager_state.bak
```

This clears the state maintained by the CPUManager so that the cpu-sets set up by the new policy won’t conflict with it.

5. Start kubelet.
    
```
# systemctl start kubelet
```

6. Undrain the node:

```
$ k uncordon node0010
```

# Verify

Default none policy for comparision:

```
# cat memory_manager_state | jq .
{
  "policyName": "None",
  "machineState": {},
  "checksum": 4236770233
}
```

Later, You should see CPU #0 is reserved for kubelet.
 
```
kubelet[2610085]: I0312 17:55:09.377656 2610085 policy_static.go:139] "Reserved CPUs not available for exclusive assignment"    reservedSize=1 reserved="0"
```

## Verify guaranteed pods getting exclusive CPUs

Apply a 150-CPU pod:

```
apiVersion: v1
kind: Pod
metadata:
  name: gengwg-test
  namespace: gengwg
spec:
  containers:
  - image: alpine
    command:
      - /bin/sh
      - "-c"
      - "sleep 6000m"
    imagePullPolicy: IfNotPresent
    name: gengwg-test
    resources:
      requests:
        cpu: 96
        memory: 1Gi
        #nvidia.com/gpu: 2
      limits:
        cpu: 96
        memory: 1Gi
        #nvidia.com/gpu: 2
  priorityClassName: high
  restartPolicy: Never
  nodeName: node0010
```

Log in to that node, and check:

```
[root@node0010 kubelet]# jq <  cpu_manager_state
{
  "policyName": "static",
  "defaultCpuSet": "0,50-127,178-255",
  "entries": {
    "b200f08b-399a-4079-bfce-e415cb5344b8": {
      "gengwg-test": "2-49,130-177" # <------------------
    },
    "d633f2d8-f174-43b3-8713-0b80d38d9259": {
      "node-exporter": "129"
    },
    "d6a85864-cf3f-45a3-baee-a9b3d5c2c4bc": {
      "driver": "128",
      "registrar": "1"
    }
  },
  "checksum": 1279870076
}
```

Verify they all belong to the same NUMA node:

```
[root@node0010 kubelet]# lscpu | grep NUMA
NUMA node(s):        2
NUMA node0 CPU(s):   0-63,128-191 # <--------
NUMA node1 CPU(s):   64-127,192-255
```

## Verify Non-guaranteed pods NOT getting exclusive CPUs

```
$ k describe po -n gengwg gengwg-test | grep cpu: -B1
    Limits:
      cpu:                2
--
    Requests:
      cpu:                1
```

It's not even in Guaranteed class:

```
$ k describe po -n gengwg gengwg-test | grep QoS
QoS Class:                   Burstable
```

Indeed, no exclusive CPUs allocated to it!

```
# cat cpu_manager_state | jq .
{
  "policyName": "static",
  "defaultCpuSet": "0,2-127,130-255",
  "entries": {
    "c049633f-a288-4c3f-a20b-69fa1bba4ca9": {
      "node-exporter": "129"
    },
    "f3209a26-d78e-4a22-81bb-55a8bcabae83": {
      "driver": "128",
      "registrar": "1"
    }
  },
  "checksum": 3270456661
}
```

## Verify Fractional requests pods NOT getting exclusive CPUs

Let's request 2.2 CPUs:

```
$ k describe po -n gengwg gengwg-test | grep cpu: -B1
    Limits:
      cpu:                2200m
--
    Requests:
      cpu:                2200m
```

It's guaranteed:

```
$ k describe po -n gengwg gengwg-test | grep QoS
QoS Class:                   Guaranteed
```

But NO exclusive CPUs allocated to it!

```
# cat cpu_manager_state | jq .
{
  "policyName": "static",
  "defaultCpuSet": "0,2-127,130-255",
  "entries": {
    "c049633f-a288-4c3f-a20b-69fa1bba4ca9": {
      "node-exporter": "129"
    },
    "f3209a26-d78e-4a22-81bb-55a8bcabae83": {
      "driver": "128",
      "registrar": "1"
    }
  },
  "checksum": 3270456661
}
```

# Troubleshooting

## Forgot to reserve CPU for kubelet

```
kubelet[2472614]: E0312 17:27:58.711824 2472614 server.go:294] "Failed to run kubelet" err="failed to run Kubelet: [cpumanager] unable to determine reserved CPU resources for static policy
```

You need reserve CPU for kubelet:

```
kubeReserved:
  cpu: "1000m" # <--- change to how much you want to reserve
```

## Forgot to remove the default none policy cpu state file

```
kubelet[2519993]: E0312 17:38:33.985052 2519993 kubelet.go:1423] "Failed to start ContainerManager" err="start cpu manager error: could not restore state from checkpoint: configured policy \"static\" differs from state checkpoint policy \"none\", please drain this node and delete the CPU manager          checkpoint file \"/var/lib/kubelet/cpu_manager_state\" before restarting Kubelet"
```

You forgot to remove the default none policy cpu state file.

## Policy start error due to discrepancy between the configuration and CPU Manager state file

```
kubelet[804460]: E0321 12:01:49.139698  804460 cpu_manager.go:226] "Policy start error" err="not all reserved cpus: \"0-1,128-129\" are present in defaultCpuSet: \"0,75-128,131,203-255\""
```

When you change to a new CPU Manager policy or configure a different number of CPUs, the CPU Manager state database file needs to be cleared for it to restart.

Delete the state database file:

```
# mv cpu_manager_state /tmp/
```

Restart kubelet

```
# systemctl restart kubelet
```

# Test exclusive CPUs?

This may have demonstrated that the CPU manager policy in question enforces exclusivity among CPUs. (Possibly just testing Qos).

## Static CPU manager policy

First apply a 150-CPU pod:

```
[root@node0010 kubelet]# jq <  cpu_manager_state
{
  "policyName": "static",
  "defaultCpuSet": "0,13-63,141-191",
  "entries": {
    "b761e594-0b6c-40e7-8dcf-bc45db599c19": {
      "gengwg-test": "2-12,64-127,130-140,192-255"
    },
    "d633f2d8-f174-43b3-8713-0b80d38d9259": {
      "node-exporter": "129"
    },
    "d6a85864-cf3f-45a3-baee-a9b3d5c2c4bc": {
      "driver": "128",
      "registrar": "1"
    }
  },
  "checksum": 636988944
}
```

Let's try schedule another 150-CPU pod on to the same node. Because `150 + 150 = 300 > 256`, it should fail. BUT should be admission error.

```
$ k get po gengwg-test2 -o wide -n gengwg -w
NAME           READY   STATUS                     RESTARTS   AGE   IP       NODE                    NOMINATED NODE   READINESS GATES
gengwg-test2   0/1     UnexpectedAdmissionError   0          11s   <none>   node0010   <none>           <none>
```

Describe the pod, gives you this reason:

```
  Warning  UnexpectedAdmissionError  102s  kubelet  Allocate failed due to not enough cpus available to satisfy request, which is unexpected
```

## Default CPU manager policy

If you do the same to a non-static CPU manager policy, 2nd pod still fails, but different error, P654099922:

```
  Warning  OutOfcpu  28s   kubelet  Node didn't have enough resource: cpu, requested: 150000, used: 153450, capacity: 256000
```

This means it passed the Admission Control stage, but failed due to node doesn't have enough CPUs.
