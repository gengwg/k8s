# Enable Memory Manager static policy in Kubelet

## TLDR

```
shutdownGracePeriod: "300s"
shutdownGracePeriodCriticalPods: "100s"
cpuManagerPolicy:  "static"
kubeReserved:
  cpu: "4000m"
  memory: "16Gi"
topologyManagerPolicy: "best-effort"
topologyManagerScope: "pod"
memoryManagerPolicy: "Static"
systemReserved:
  memory: "4Gi"
evictionHard:
  memory.available: "512Mi"
reservedMemory:
  - numaNode: 0
    limits:
      memory: "10496Mi"
  - numaNode: 1
    limits:
      memory: "10496Mi"
```

## Troubleshooting

If you simply set memoryManagerPolicy to "Static", and nothing else:

```
memoryManagerPolicy: "Static"
```

You will get error:

```
E0325 10:34:52.606769 3928153 server.go:294] "Failed to run kubelet" err="failed to run Kubelet: the total amount \"0\" of type \"memory\" is not equal to the value \"16484Mi\" determined by Node Allocatable feature"
```

This is you didn't set the reservedMemory (0 as shown).

I see this:

```
kubeReserved:
  cpu: "4000m"
  memory: "16Gi"
```

I thought `reservedMemory: 16484Mi + 100Mi = 16548Mi`

So I set something like this:

```
reservedMemory:
  - numaNode: 0
    limits:
      memory: "16548Mi"
```

Now got new error:

```
E0325 10:50:33.312005 3992742 server.go:294] "Failed to run kubelet" err="failed to run Kubelet: the total amount \"16548Mi\" of type \"memory\" is not equal to the value \"16484Mi\" determined by Node Allocatable feature"
```

This is because I calculated the reserved memory wrong. It should be:

```
>>> 16 Gi *1024 =16384 Mi + 100 Mi= 16484 Mi
```

the extra 100 Mi is the default eviction hardlimit.

Now works:

```
# jq < memory_manager_state
{
  "policyName": "Static",
  "machineState": {
    "0": {
      "numberOfAssignments": 15,
      "memoryMap": {
        "hugepages-1Gi": {
          "total": 0,
          "systemReserved": 0,
          "allocatable": 0,
          "reserved": 0,
          "free": 0
        },
        "hugepages-2Mi": {
          "total": 0,
          "systemReserved": 0,
          "allocatable": 0,
          "reserved": 0,
          "free": 0
        },
        "memory": {
          "total": 540065116160,
          "systemReserved": 17284726784,
          "allocatable": 522780389376,
          "reserved": 479743991808,
          "free": 43036397568
        }
      },
      "cells": [
        0
      ]
    },
.....
```

Now let's try to reserve memory from 2 NUMA nodes. Also we reserve 1Gi for system, 200Mi for evictionHard.

Now the reserved memory for each numa node should be:

```
>>> (16*1024 +200 +1024 )/2
8804.0
```

Resulted kubelet config:

```
memoryManagerPolicy: "Static"
systemReserved:
  memory: "1Gi"
evictionHard:
  memory.available: "200Mi"
reservedMemory:
  - numaNode: 0
    limits:
      memory: "8804Mi"
  - numaNode: 1
    limits:
      memory: "8804Mi"
```

worked!





