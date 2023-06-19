## Notes

Dex Allow User to Securely Authenticate (LDAP) and Generate OAUTH2 Token which can be used to apply Kubernetes RBAC. Anyone with a valid unix account to be able to login to our kubernetes clusters via 'kubectl_login'.

ID tokens are normally intended for sing-on, access tokens for calling protected APIs.

## Commands

### Verify Dex server working or not

A working Dex server should be like this:

```
gengwg@gengwg-mbp:~$ curl https://mydex.myco.com/dex/.well-known/openid-configuration
{
  "issuer": "https://mydex.myco.com/dex",
  "authorization_endpoint": "https://mydex.myco.com/dex/auth",
  "token_endpoint": "https://mydex.myco.com/dex/token",
  "jwks_uri": "https://mydex.myco.com/dex/keys",
  "userinfo_endpoint": "https://mydex.myco.com/dex/userinfo",
  "device_authorization_endpoint": "https://mydex.myco.com/dex/device/code",
  "grant_types_supported": [
    "authorization_code",
    "refresh_token",
    "urn:ietf:params:oauth:grant-type:device_code"
  ],
  "response_types_supported": [
    "code"
  ],
  "subject_types_supported": [
    "public"
  ],
  "id_token_signing_alg_values_supported": [
    "RS256"
  ],
  "scopes_supported": [
    "openid",
    "email",
    "groups",
    "profile",
    "offline_access"
  ],
  "token_endpoint_auth_methods_supported": [
    "client_secret_basic"
  ],
  "claims_supported": [
    "aud",
    "email",
    "email_verified",
    "exp",
    "iat",
    "iss",
    "locale",
    "name",
    "sub"
  ]
}
```

### Checking bearer token for dex:

```
$ cat .kube/config | grep id-token
```

Then use JWT tools to decode the id-token.

### API Server configs for dex/oidc openID connect tokens

```
$ sudo cat /etc/systemd/system/kube-apiserver.service | grep oidc
  --oidc-issuer-url=https://mydex.myco.com/dex \
  --oidc-client-id=loginapp \
  --oidc-ca-file=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
  --oidc-username-claim=name \
  --oidc-groups-claim=groups \
```

NOTE: If a claim other than “email” is used for username, for example “sub”, it will be prefixed by "(value of --oidc-issuer-url)#". This is to namespace user controlled claims which may be used for privilege escalation.

## Tutorials

### Store Dex state in etcd database to ensure high availability and scalability

Dex is an identity provider that specializes in OpenID Connect and OAuth2. However, it is important to note that Dex is not completely stateless. For instance, user data, client information, tokens, and other crucial data utilized in the authentication process are securely stored by Dex. In our present configuration, we store this state in the memory of the local instance in-memory datastore. Unfortunately, this limitation prevents us from running more than 1 replica since multiple instances would result in inconsistent data.

By storing the state of Dex in an external database, we can enhance the scalability of Dex deployment and achieve high availability (HA) for Dex. More information on this topic can be found in the [HA for Dex discussion](https://github.com/dexidp/dex/discussions/2256). Dex offers support for multiple data [storage backends](https://dexidp.io/docs/storage/). I opted for etcd because it is already available. We don't need to set up a new MySQL or any other cluster solely for storing the state of Dex!

Steps:

1. Update the dex config map

```
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dex
  namespace: auth
data:
  config.yaml: |
    issuer: https://mydex.example.com/dex
    storage:
      type: etcd  # <----- here and below
      config:
        endpoints:
          - https://ctrlplane01.example.com:2379
          - https://ctrlplane02.example.com:2379
          - https://ctrlplane03.example.com:2379
        ssl:
          # mounted from host. see below deployment
          caFile: /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
          keyFile: /opt/kubernetes/pki/keys/calico.key
          certFile: /opt/kubernetes/pki/certs/calico.pem

    logger:
      level: "debug"

    web:
      https: 0.0.0.0:5556
      tlsCert: /etc/dex/tls/tls.crt
      tlsKey: /etc/dex/tls/tls.key
.....
```

Compare original:

```
    storage:
      type: kubernetes
      config:
        kubeConfigFile: /etc/cni/net.d/calico-kubeconfig
```

2. Then edit the dex deployment. 

Commented lines are added. Rest are original.

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: dex
  name: dex
  namespace: auth
spec:
  replicas: 3
  selector:
    matchLabels:
      app: dex
  template:
    metadata:
      labels:
        app: dex
    spec:
      containers:
      - image: dtr.example.com/k8s/dex:2.25.0
        name: dex
        command: ["dex", "serve", "/etc/dex/cfg/config.yaml"]
        securityContext: # Add
          allowPrivilegeEscalation: true
          capabilities:
            add:
            - SYS_ADMIN
          privileged: true
          runAsUser: 0
        ports:
        - name: https
          containerPort: 5556
        volumeMounts:
        - name: config
          mountPath: /etc/dex/cfg
        - name: tls
          mountPath: /etc/dex/tls
        - name: certs
          mountPath: /etc/cni/net.d/
        - name: ca-cert
          mountPath: /etc/pki/ca-trust/extracted/pem/
        - mountPath: /opt/kubernetes/pki/ # mount host calico certs to container
          name: node-certs
        envFrom:
        - secretRef:
            name: ldap-cred
      topologySpreadConstraints:
      - labelSelector:
          matchLabels:
            app: dex
        maxSkew: 1
        topologyKey: kubernetes.io/hostname
        # tell the scheduler try to schedule the pod even if the constraint cannot be met
        # we do not want dex to be not scheduled!
        whenUnsatisfiable: ScheduleAnyway
      volumes:
      - name: certs
        hostPath:
          path: /etc/cni/net.d/
      - name: ca-cert
        hostPath:
          path: /etc/pki/ca-trust/extracted/pem/
      - name: config
        configMap:
          name: dex
          items:
          - key: config.yaml
            path: config.yaml
      - name: tls
        secret:
          secretName: mydex.example.com
      - hostPath: # Add calico certs host path
          path: /opt/kubernetes/pki/
          type: ""
        name: node-certs
```

NOTE: I am adding the securityContext for the Dex pod because the Calico key is currently only readable by the root user. If we can relax this restriction, we can remove the securityContext.

```
        securityContext: # Add
          allowPrivilegeEscalation: true
          capabilities:
            add:
            - SYS_ADMIN
          privileged: true
          runAsUser: 0
```

Here is the current permission of the Calico key file:

```
# ll /opt/kubernetes/pki/keys/calico.key
-rw------- 1 root root 1704 Oct 19 2022 /opt/kubernetes/pki/keys/calico.key
```

On the other hand, the permissions for the Calico kubeconfig file are world readable:

```
# ll /etc/cni/net.d/calico-kubeconfig
-rw-r--r-- 1 root root 489096 Oct 19 2022 /etc/cni/net.d/calico-kubeconfig
```

3. Test

- Run `kubectl login` again to make sure able to login.
- Run `k get pods` to make sure kubectl still works.
- Check Dex logs to see any errors.
- Decode the JWT login token in `~/.kube/config` generated by Dex, and inspect dates, groups, etc..

That's it. Now you can specify multiple replicas in your Dex deployment and not worry about data inconsistency between different DEx pods!

```
spec:
  replicas: 3
  selector:
    matchLabels:
      app: dex
```

## Troubleshooting

### exec format error

```
$ k get po
NAME                   READY   STATUS             RESTARTS     AGE
dex-5c5bfc6856-rgrkt   0/1     CrashLoopBackOff   1 (9s ago)   16s
dex-744f757cc6-bc4gr   1/1     Running            0            2m31s
dex-744f757cc6-c2bcn   1/1     Running            0            2m25s
dex-744f757cc6-lnxm5   1/1     Running            0            2m29s
$ k logs dex-5c5bfc6856-rgrkt
exec /usr/local/bin/dex: exec format error
```

This is due to the pull/pushed image is arm need pull amd64.

```
$ docker pull --platform=linux/amd64  ghcr.io/dexidp/dex:v2.35.0
$ docker tag ghcr.io/dexidp/dex:v2.35.0 harbor.my.com/ghcr.io/dex:v2.35.0
$ docker push harbor.my.com/ghcr.io/dex:v2.35.0
```

(Possibly also need purge images on the worker nodes, due to imagePullPolicy.)

Now good:

```
$ k tree deploy dex
NAMESPACE  NAME                          READY  REASON  AGE
auth	   Deployment/dex                -              11m
auth	   ├─ReplicaSet/dex-584c98d68f   -              11m
auth	   ├─ReplicaSet/dex-5c5bfc6856   -              6m15s
auth	   ├─ReplicaSet/dex-68d469ff8b   -              2m50s
auth	   ├─ReplicaSet/dex-744f757cc6   -              8m30s
auth	   └─ReplicaSet/dex-755d478747   -              28s
auth	     ├─Pod/dex-755d478747-6mk5z  True           28s
auth	     ├─Pod/dex-755d478747-7mgp9  True           21s
auth	     └─Pod/dex-755d478747-ffmdc  True           15s
```

### AuthCode CRD validation failed.

```
$ k apply -f kubernetes/clusters/dev/dex.yaml
namespace/auth unchanged
error: error validating "kubernetes/clusters/dev/dex.yaml": error validating data: [ValidationError(CustomResourceDefinition.spec): unknown field "version" in io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1.CustomResourceDefinitionSpec, ValidationError(CustomResourceDefinition.spec): missing required field "versions" in io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1.CustomResourceDefinitionSpec]; if you choose to ignore these errors, turn validation off with --validate=false
```

This is due to K8s upgraded and CRD API changed. Using [latest CRD](https://github.com/dexidp/dex/blob/master/scripts/manifests/crds/authcodes.yaml) from official repo fixed it.

```
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: authcodes.dex.coreos.com
spec:
  group: dex.coreos.com
  names:
    kind: AuthCode
    listKind: AuthCodeList
    plural: authcodes
    singular: authcode
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
```

A few core APIs also changed. Simply check the latest api versions:

```
$ k diff -f kubernetes/clusters/dev/dex.yaml
error: unable to recognize "kubernetes/clusters/dev/dex.yaml": no matches for kind "CustomResourceDefinition" in version "apiextensions.k8s.io/v1beta1"
$ k api-resources  | grep apiex
customresourcedefinitions         crd,crds                      apiextensions.k8s.io/v1                  false        CustomResourceDefinition

$ k diff -f kubernetes/clusters/dev/dex.yaml
error: unable to recognize "kubernetes/clusters/dev/dex.yaml": no matches for kind "ClusterRole" in version "rbac.authorization.k8s.io/v1beta1"
$ k api-resources  | grep clusterroles
clusterroles                                                    rbac.authorization.k8s.io/v1             false        ClusterRole
```

Final Cluster role (binding) looks like this:

```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dex
rules:
- apiGroups: ["dex.coreos.com"] # API group created by dex
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["create"] # To manage its own resources identity must be able to create customresourcedefinitions.
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dex
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dex
subjects:
- kind: ServiceAccount
  name: dex                 # Service account assigned to the dex pod.
  namespace: auth           # The namespace dex is running in.
- kind: Group
  name: system:nodes        # access to system:nodes group on dex.coreos.com apis
  namespace: auth
```
