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
