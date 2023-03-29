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

## Steps

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


Now let's try again, and reserve 4Gi for system, 512Mi for evictionHard.

Each Numa node should reserve:

```
>>> (16*1024 +512 +1024*4 )/2
10496.0
```

Resulted config:

```
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

That's it.

## Automation

Each time you changed the memory policy config, you have to delete the db state file. This is manual and time consuming. 

My current automation is to create a systemd dropin file, e.g. remove_memory_manager_state.conf to remove the state file before each restart of kubelet:

```
[Service]
ExecStartPre=/usr/bin/rm -rf /var/lib/kubelet/memory_manager_state
```

One can test it like this:

```
# ll memory_manager_state
-rw------- 1 root root 61 Mar 27 13:57 memory_manager_state
# sudo systemctl restart kubelet
# ll memory_manager_state
ls: cannot access 'memory_manager_state': No such file or directory
# ll memory_manager_state
-rw------- 1 root root 61 Mar 27 13:57 memory_manager_state
```

Example Chef code:

```
# Set the path to the kubelet systemd directory.
kubelet_systemd_dir = '/etc/systemd/system/kubelet.service.d/'

# On CentOS 8 only, create the kubelet systemd directory.
if node.centos8?
  directory kubelet_systemd_dir do
    owner  'root'
    group  'root'
    mode   '0755'
  end

  # Create a systemd drop-in configuration file to remove the memory_manager_state file pre-start
  template "#{kubelet_systemd_dir}/remove_memory_manager_state.conf" do
    source 'remove_memory_manager_state.conf.erb'
    owner  'root'
    group  'root'
    mode   '0644'
    action :create
    notifies :run, 'systemd_reload[system instance]', :immediately
    notifies :restart, 'service[kubelet]', :delayed
  end
end
```


### Tradeoffs of this implementation

NOTE: These details pertain to version 1.22. I am uncertain if there have been improvements in version 1.26 at the time of writing.

The concept is straightforward, but the implementation is not trivial.

The idea is that each time the topology policy is modified, (e.g. changing Memories reserved, etc.) the state of the corresponding topology (CPU, memory) needs to be cleared. However, when using Chef for implementation, certain tradeoffs need to be made.

With human intelligence, we would know whether we are modifying a topology policy or other components of the kubelet configuration and accordingly determine whether to remove the state file or not. However, Chef is not as intelligent (yet).

You can clear the state at the following times:

- Only when the policy name changes (e.g. none <--> static).
  - It turns out that you need to clear the state when you change other components of the policy as well, such as reserving more memory or CPU.
- At each Chef run.
  - This works, but it's overkill to clear the state every 30 minutes.
- When the kubelet config changes.
  - In my opinion, this is the best balance so far.
  - We probably haven't changed the kubelet config for a very long time, until recently when I started working on topology-aware scheduling.
  - Even if the state gets cleared by changes other than the topology policy, it doesn't cause any damage, and the pods continue to run.
- Only when the topology policy changes.
  - This is the perfect case in theory, but it's not possible to implement it in reality.
  - Essentially, you will be managing a state database using Chef! It's better to manage it using Golang/k8s.
