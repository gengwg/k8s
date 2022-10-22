#!/usr/bin/env python3

"""
List Namespaces with their oncall labels.

Example Usage:

./get_ns_oncall_label.py
NAMESPACE                      ONCALL
auth                           my_oncall
cert-manager                   your_oncall
....
"""

from kubernetes import client, config

# Configs can be set in Configuration class directly or using helper utility
config.load_kube_config()

v1 = client.CoreV1Api()
ret = v1.list_namespace()

print(f'{"Namespace".upper():<30} {"Oncall".upper()}')
for i in ret.items:
    print(f"{i.metadata.name:<30} {i.metadata.labels['oncall']}")
