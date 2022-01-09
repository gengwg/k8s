# Deploy a Kubernetes Cluster Using VirtualBox

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

Cluster configuration:

- 1 control plane
- 2 worker nodes
- OS: `config.vm.box = "ubuntu/bionic64"`
- Setup Tool: kubeadm
- K8s version: 1.21.0

## Provision VMs with Vagrant

    vagrant up

## Letting iptables see bridged traffic

SSH to all nodes, using 3 terminals. for example:

```
$ vagrant ssh kubemaster
$ vagrant ssh kubenode01
$ vagrant ssh kubenode02
```

Make sure that the br_netfilter module is loaded. 

```
lsmod | grep br_netfilter
sudo modprobe br_netfilter
lsmod | grep br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
```

Example:

```
vagrant@kubemaster:~$ lsmod | grep br_n
vagrant@kubemaster:~$ sudo modprobe br_netfilter
vagrant@kubemaster:~$ lsmod | grep br_n
br_netfilter           24576  0
bridge                155648  1 br_netfilter
vagrant@kubemaster:~$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
> br_netfilter
> EOF
br_netfilter
vagrant@kubemaster:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.bridge.bridge-nf-call-ip6tables = 1
> net.bridge.bridge-nf-call-iptables = 1
> EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vagrant@kubemaster:~$ sudo sysctl --system
* Applying /etc/sysctl.d/10-console-messages.conf ...
kernel.printk = 4 4 1 7
* Applying /etc/sysctl.d/10-ipv6-privacy.conf ...
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
* Applying /etc/sysctl.d/10-kernel-hardening.conf ...
kernel.kptr_restrict = 1
* Applying /etc/sysctl.d/10-link-restrictions.conf ...
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
* Applying /etc/sysctl.d/10-lxd-inotify.conf ...
fs.inotify.max_user_instances = 1024
* Applying /etc/sysctl.d/10-magic-sysrq.conf ...
kernel.sysrq = 176
* Applying /etc/sysctl.d/10-network-security.conf ...
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
* Applying /etc/sysctl.d/10-ptrace.conf ...
kernel.yama.ptrace_scope = 1
* Applying /etc/sysctl.d/10-zeropage.conf ...
vm.mmap_min_addr = 65536
* Applying /usr/lib/sysctl.d/50-default.conf ...
net.ipv4.conf.all.promote_secondaries = 1
net.core.default_qdisc = fq_codel
* Applying /etc/sysctl.d/99-cloudimg-ipv6.conf ...
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.default.use_tempaddr = 0
* Applying /etc/sysctl.d/99-sysctl.conf ...
* Applying /etc/sysctl.d/k8s.conf ...
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.conf ...
```

Same on other nodes:

```
vagrant@kubenode01:~$ lsmod | grep br_netfilter
vagrant@kubenode01:~$ sudo modprobe br_netfilter
vagrant@kubenode01:~$ lsmod | grep br_netfilter
br_netfilter           24576  0
bridge                155648  1 br_netfilter
vagrant@kubevagrant@kubenode01:~$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
> br_netfilter
> EOF
node01:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.bridge.bridge-nf-call-ip6tables = 1
> net.bridge.bridge-nf-call-iptables = 1
> EOF
vagrant@kubenode01:~$ sudo sysctl --system
```

## Installing runtime 

We are using Docker, so follow here:

https://docs.docker.com/engine/install/ubuntu/


```
vagrant@kubemaster:~$ sudo apt-get remove docker docker-engine docker.io containerd runc
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Package 'docker-engine' is not installed, so not removed
Package 'docker' is not installed, so not removed
Package 'containerd' is not installed, so not removed
Package 'docker.io' is not installed, so not removed
Package 'runc' is not installed, so not removed
0 upgraded, 0 newly installed, 0 to remove and 7 not upgraded.
vagrant@kubemaster:~$ sudo apt-get install \
>     ca-certificates \
>     curl \
>     gnupg \
>     lsb-release
Reading package lists... Done
Building dependency tree       
Reading state information... Done
lsb-release is already the newest version (9.20170808ubuntu1).
lsb-release set to manually installed.
ca-certificates is already the newest version (20210119~18.04.2).
ca-certificates set to manually installed.
curl is already the newest version (7.58.0-2ubuntu3.16).
curl set to manually installed.
gnupg is already the newest version (2.2.4-1ubuntu1.4).
gnupg set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 7 not upgraded.
```


Add Docker’s official GPG key:

```
vagrant@kubemaster:~$  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
gpg: WARNING: unsafe ownership on homedir '/home/vagrant/.gnupg'

```

Set up the stable repository. 

```
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker Engine

```
 sudo apt-get update
 sudo apt-get install docker-ce docker-ce-cli containerd.io

```

Configure the Docker daemon, in particular to use systemd for the management of the container’s cgroups.

```
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```

Restart Docker and enable on boot:

```
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

**Repeat on all nodes.**

##  Installing kubeadm, kubelet and kubectl 


Install the kubeadm packages on the controlplane and worker nodes. Use the exact version of `1.21.0-00`.

Update the apt package index and install packages needed to use the Kubernetes apt repository:

    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl

Download the Google Cloud public signing key:

    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

Add the Kubernetes apt repository:

    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

    sudo apt-get update
    # install latest version
    # sudo apt-get install -y kubelet kubeadm kubectl
    # install exact version:
    sudo apt-get install -y kubelet=1.21.0-00 kubeadm=1.21.0-00 kubectl=1.21.0-00
    sudo apt-mark hold kubelet kubeadm kubectl

**Reapeat on all nodes.**

What is the version of kubelet installed?

```
vagrant@kubemaster:~$ kubelet --version
Kubernetes v1.21.0
```

kubectl not working yet:

```
vagrant@kubemaster:~$ kubectl get no
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

## Initializing your control-plane node 

Lets now bootstrap a kubernetes cluster using kubeadm.

Initialize Control Plane Node (Master Node). Use the following options:

    apiserver-advertise-address - Use the IP address allocated to eth0 on the controlplane node

    apiserver-cert-extra-sans - Set it to controlplane

    pod-network-cidr - Set to 10.244.0.0/16


```
vagrant@kubemaster:~$ ip a 
 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:24:5f:5f:ac:56 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 81530sec preferred_lft 81530sec
    inet6 fe80::24:5fff:fe5f:ac56/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:f0:ea:14 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.2/24 brd 192.168.56.255 scope global enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fef0:ea14/64 scope link 
       valid_lft forever preferred_lft forever
```

    sudo kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address 192.168.56.2 --pod-network-cidr=10.244.0.0/16


Outputs:

```
vagrant@kubemaster:~$ sudo kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address 192.168.56.2 --pod-network-cidr=10.244.0.0/16
I0109 18:09:59.416095    8776 version.go:254] remote version is much newer: v1.23.1; falling back to: stable-1.21
[init] Using Kubernetes version: v1.21.8
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [controlplane kubemaster kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.56.2]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubemaster localhost] and IPs [192.168.56.2 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubemaster localhost] and IPs [192.168.56.2 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[kubelet-check] Initial timeout of 40s passed.
[apiclient] All control plane components are healthy after 67.519078 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.21" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node kubemaster as control-plane by adding the labels: [node-role.kubernetes.io/master(deprecated) node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node kubemaster as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: ogj18n.xdrkf88sqhaqg7vg
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.56.2:6443 --token ogj18n.xdrkf88sqhaqg7vg \
	--discovery-token-ca-cert-hash sha256:335215511deeb0218cdee8dd086efab660b58b5253d9dafa0f4c9b409e7db1bc
```


Once done, set up the default kubeconfig file and wait for node to be part of the cluster.

Outputs:

```
vagrant@kubemaster:~$   mkdir -p $HOME/.kube
vagrant@kubemaster:~$   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
vagrant@kubemaster:~$   sudo chown $(id -u):$(id -g) $HOME/.kube/config
vagrant@kubemaster:~$ kubectl get no
NAME         STATUS     ROLES                  AGE   VERSION
kubemaster   NotReady   control-plane,master   32s   v1.21.0
```

## Join worker nodes to the cluster using the join token     

Join both node01 and node02 to the cluster using the join token:

```
sudo kubeadm join 192.168.56.2:6443 --token ogj18n.xdrkf88sqhaqg7vg --discovery-token-ca-cert-hash sha256:335215511deeb0218cdee8dd086efab660b58b5253d9dafa0f4c9b409e7db1bc 
```

Example:

```
vagrant@kubenode01:~$ sudo !!
sudo kubeadm join 192.168.56.2:6443 --token ogj18n.xdrkf88sqhaqg7vg --discovery-token-ca-cert-hash sha256:335215511deeb0218cdee8dd086efab660b58b5253d9dafa0f4c9b409e7db1bc 
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

vagrant@kubenode02:~$ sudo kubeadm join 192.168.56.2:6443 --token ogj18n.xdrkf88sqhaqg7vg --discovery-token-ca-cert-hash sha256:335215511deeb0218cdee8dd086efab660b58b5253d9dafa0f4c9b409e7db1bc
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

Check nodes joined the cluster one by one:

```
vagrant@kubemaster:~$ kubectl get no
NAME         STATUS     ROLES                  AGE   VERSION
kubemaster   NotReady   control-plane,master   29m   v1.21.0
kubenode01   NotReady   <none>                 3s    v1.21.0
vagrant@kubemaster:~$ kubectl get no
NAME         STATUS     ROLES                  AGE   VERSION
kubemaster   NotReady   control-plane,master   30m   v1.21.0
kubenode01   NotReady   <none>                 49s   v1.21.0
kubenode02   NotReady   <none>                 21s   v1.21.0
```


## Installing a Pod network add-on

You must deploy a Container Network Interface (CNI) based Pod network add-on so that your Pods can communicate with each other. Cluster DNS (CoreDNS) will not start up before a network is installed.

You can install only one Pod network per cluster. So use one and only one below.

### Install Calico

https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart

Install the Tigera Calico operator and custom resource definitions.

```
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
```

Install Calico by creating the necessary custom resource. 

```
vagrant@kubemaster:~$ wget https://docs.projectcalico.org/manifests/custom-resources.yaml
```

Modify the `cidr` to be the same you set up for the `pod-network-cidr` above for the api server.

```
vagrant@kubemaster:~$ vim custom-resources.yaml 
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      #cidr: 192.168.0.0/16
      cidr: 10.244.0.0/16
      encapsulation: VXLANCrossSubnet

```

Apply

```
vagrant@kubemaster:~$ kubectl apply -f custom-resources.yaml 
installation.operator.tigera.io/default created
apiserver.operator.tigera.io/default created
```

Wait until the network pods are ready:

```
vagrant@kubemaster:~$ watch kubectl get pods -n calico-system
vagrant@kubemaster:~$ kubectl get pods -n calico-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-58494599f9-xk5sb   1/1     Running   0          56m
calico-node-8sjvf                          1/1     Running   0          56m
calico-node-gs2fn                          1/1     Running   0          56m
calico-node-rwx96                          1/1     Running   0          56m
calico-typha-7db9f445b5-h69pd              1/1     Running   0          56m
calico-typha-7db9f445b5-wjrmj              1/1     Running   0          56m
```

Now you can see your nodes Status becomes Ready!

```
vagrant@kubemaster:~$ kubectl get no
NAME         STATUS   ROLES                  AGE   VERSION
kubemaster   Ready    control-plane,master   40m   v1.21.0
kubenode01   Ready    <none>                 10m   v1.21.0
kubenode02   Ready    <none>                 10m   v1.21.0
```

The CoreDNS pods are ready too!

```
vagrant@kubemaster:~$ kubectl get po -n kube-system
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-558bd4d5db-5b5tp             1/1     Running   0          75m
coredns-558bd4d5db-ggjt4             1/1     Running   0          75m
etcd-kubemaster                      1/1     Running   0          75m
kube-apiserver-kubemaster            1/1     Running   0          75m
kube-controller-manager-kubemaster   1/1     Running   0          75m
kube-proxy-bl7k6                     1/1     Running   0          75m
kube-proxy-ff4hm                     1/1     Running   0          45m
kube-proxy-nb5p8                     1/1     Running   0          45m
kube-scheduler-kubemaster            1/1     Running   0          75m
vagrant@kubemaster:~$ 

```

Deploy a test pod to verify able to deploy!

```
vagrant@kubemaster:~$ kubectl run test --image nginx
pod/test created
```

Note the IP is within the range of CIDR specified in Calico config.

```
vagrant@kubemaster:~$ kubectl get po -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
test   1/1     Running   0          10m   10.244.96.3   kubenode02   <none>           <none>
```

### Install Flannel

If you want to use Flannel. 

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

The End.

