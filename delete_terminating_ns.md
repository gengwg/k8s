How to delete namespaces stuck in the "Terminating" status.


# Problem

```
$ k create ns myns
namespace/myns created
$ k delete ns myns
namespace "myns" deleted
^C
$ k get ns myns
NAME   STATUS        AGE
myns   Terminating   18s
```

Even force delete not work.

```
$ k delete ns test --grace-period=0 --force
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
namespace "test" force deleted
^C

$ k get all -n test
No resources found in test namespace.
```

# Fix

1. Save the json.

```
$ k get ns myns -o json > myns.json

```

2.    Edit the JSON file and remove the finalizers from the array.

Remove below line:

```
        "finalizers": [
            "kubernetes" # <---- remove this line
        ]
```

It should look like this:

```
$ cat myns.json
{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "creationTimestamp": "2022-06-21T18:59:45Z",
        "deletionTimestamp": "2022-06-21T18:59:49Z",
        "labels": {
            "kubernetes.io/metadata.name": "myns"
        },
        "name": "myns",
        "resourceVersion": "132095608",
        "uid": "ab9c7bc0-6e4c-4d8a-930a-f106e2c32d1a"
    },
    "spec": {
    },
    "status": {
        "conditions": [
            {
                "lastTransitionTime": "2022-06-21T18:59:54Z",
                "message": "Discovery failed for some groups, 1 failing: unable to retrieve the complete list of server APIs: metrics.k8s.io/v1beta1: the server is currently unable to handle the request",
                "reason": "DiscoveryFailed",
                "status": "True",
                "type": "NamespaceDeletionDiscoveryFailure"
            },
            {
                "lastTransitionTime": "2022-06-21T18:59:54Z",
                "message": "All legacy kube types successfully parsed",
                "reason": "ParsedGroupVersions",
                "status": "False",
                "type": "NamespaceDeletionGroupVersionParsingFailure"
            },
            {
                "lastTransitionTime": "2022-06-21T18:59:54Z",
                "message": "All content successfully deleted, may be waiting on finalization",
                "reason": "ContentDeleted",
                "status": "False",
                "type": "NamespaceDeletionContentFailure"
            },
            {
                "lastTransitionTime": "2022-06-21T18:59:54Z",
                "message": "All content successfully removed",
                "reason": "ContentRemoved",
                "status": "False",
                "type": "NamespaceContentRemaining"
            },
            {
                "lastTransitionTime": "2022-06-21T18:59:54Z",
                "message": "All content-preserving finalizers finished",
                "reason": "ContentHasNoFinalizers",
                "status": "False",
                "type": "NamespaceFinalizersRemaining"
            }
        ],
        "phase": "Terminating"
    }
}
```

3. apply the change

```
$ kubectl replace --raw "/api/v1/namespaces/myns/finalize" -f ./myns.json
{"kind":"Namespace","apiVersion":"v1","metadata":{"name":"myns","uid":"ab9c7bc0-6e4c-4d8a-930a-f106e2c32d1a","resourceVersion":"132095608","creationTimestamp":"2022-06-21T18:59:45Z","deletionTimestamp":"2022-06-21T18:59:49Z","labels":{"kubernetes.io/metadata.name":"myns"},"managedFields":[{"manager":"kubectl-create","operation":"Update","apiVersion":"v1","time":"2022-06-21T18:59:45Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:kubernetes.io/metadata.name":{}}}}},{"manager":"kube-controller-manager","operation":"Update","apiVersion":"v1","time":"2022-06-21T18:59:54Z","fieldsType":"FieldsV1","fieldsV1":{"f:status":{"f:conditions":{".":{},"k:{\"type\":\"NamespaceContentRemaining\"}":{".":{},"f:lastTransitionTime":{},"f:message":{},"f:reason":{},"f:status":{},"f:type":{}},"k:{\"type\":\"NamespaceDeletionContentFailure\"}":{".":{},"f:lastTransitionTime":{},"f:message":{},"f:reason":{},"f:status":{},"f:type":{}},"k:{\"type\":\"NamespaceDeletionDiscoveryFailure\"}":{".":{},"f:lastTransitionTime":{},"f:message":{},"f:reason":{},"f:status":{},"f:type":{}},"k:{\"type\":\"NamespaceDeletionGroupVersionParsingFailure\"}":{".":{},"f:lastTransitionTime":{},"f:message":{},"f:reason":{},"f:status":{},"f:type":{}},"k:{\"type\":\"NamespaceFinalizersRemaining\"}":{".":{},"f:lastTransitionTime":{},"f:message":{},"f:reason":{},"f:status":{},"f:type":{}}}}},"subresource":"status"}]},"spec":{},"status":{"phase":"Terminating","conditions":[{"type":"NamespaceDeletionDiscoveryFailure","status":"True","lastTransitionTime":"2022-06-21T18:59:54Z","reason":"DiscoveryFailed","message":"Discovery failed for some groups, 1 failing: unable to retrieve the complete list of server APIs: metrics.k8s.io/v1beta1: the server is currently unable to handle the request"},{"type":"NamespaceDeletionGroupVersionParsingFailure","status":"False","lastTransitionTime":"2022-06-21T18:59:54Z","reason":"ParsedGroupVersions","message":"All legacy kube types successfully parsed"},{"type":"NamespaceDeletionContentFailure","status":"False","lastTransitionTime":"2022-06-21T18:59:54Z","reason":"ContentDeleted","message":"All content successfully deleted, may be waiting on finalization"},{"type":"NamespaceContentRemaining","status":"False","lastTransitionTime":"2022-06-21T18:59:54Z","reason":"ContentRemoved","message":"All content successfully removed"},{"type":"NamespaceFinalizersRemaining","status":"False","lastTransitionTime":"2022-06-21T18:59:54Z","reason":"ContentHasNoFinalizers","message":"All content-preserving finalizers finished"}]}}
```

4.    Verify that the terminating namespace is removed:


```
$ k get ns myns
Error from server (NotFound): namespaces "myns" not found
```

