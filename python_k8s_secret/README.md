# hello_secret

Deploy Kubernetes secrets to your namespace, and use it in your Python app.

# 1. Base64 encode the password

Assuming your password is `hellopass`.

```
$ echo -n "hellopass" | base64
aGVsbG9wYXNz
```

# 2. Create the secret

```
$ cat secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: "mysecret"
data:
  mypass: "aGVsbG9wYXNz"
```

# 3. Refreence the secret's values in your Python app using environmental variable

```
$ cat app.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  namespace: myns
spec:
  containers:
  - name: test
    image: python
    command:
    - python3
    - -c
    - "import os;print(os.environ['PASSWORD'])"
    env:
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: mypass
```


# 4. Check the app got the secret successfully

Run it:

```
$ k apply -k .
namespace/myns created
secret/mysecret created
pod/mypod created
```

Wait until app is deployed:

```
$ k get po -n myns
NAME    READY   STATUS      RESTARTS   AGE
mypod   0/1     Completed   2          37s
```

Confirm secret is deployed:

```
$ k get secret  -n myns
NAME                  TYPE                                  DATA   AGE
default-token-chqpj   kubernetes.io/service-account-token   3      9m39s
mysecret              Opaque                                1      9m39s
```

Check the logs/standard output:

```
$ k logs mypod -n myns
hellopass <---- confirms
```
