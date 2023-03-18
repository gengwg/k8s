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
    
