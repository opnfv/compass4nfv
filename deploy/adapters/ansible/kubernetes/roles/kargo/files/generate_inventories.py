##############################################################################
# Copyright (c) 2016-2018 compass4nfv and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import yaml
import sys
import os
from jinja2 import Environment
try:
    import json
except ImportError:
    import simplejson as json

INVENTORY_TEMPLATE = """
[all]
{% for host, vales in hostvars.iteritems() %}
{{ host }} ansible_ssh_host={{ vales['ansible_ssh_host'] }} \
ansible_ssh_pass=root  ansible_user=root
{% endfor %}
[kube-master]
{% for host in kube_master %}
{{ host }}
{% endfor %}

[etcd]
{% for host in etcd %}
{{ host }}
{% endfor %}

[kube-node]
{% for host in kube_node %}
{{ host }}
{% endfor %}

[k8s-cluster:children]
kube-node
kube-master

[calico-rr]
[vault]
"""


def _byteify(data, ignore_dicts=False):

    if isinstance(data, unicode):
        return data.encode('utf-8')
    if isinstance(data, list):
        return [_byteify(item, ignore_dicts=True) for item in data]
    if isinstance(data, dict) and not ignore_dicts:
        return {
            _byteify(key, ignore_dicts=True):
            _byteify(value, ignore_dicts=True)
            for key, value in data.iteritems()
        }
    return data


def load_inventory(inventory):
    if not os.path.exists(inventory):
        raise RuntimeError('file: %s not exist' % inventory)
    with open(inventory, 'r') as fd:
        return json.load(fd, object_hook=_byteify)


def create_inventory_file(inventories_path,
                          hostvars, kube_master, etcd, kube_node):
    content = Environment().from_string(INVENTORY_TEMPLATE).render(
              hostvars=hostvars, kube_master=kube_master,
              etcd=etcd, kube_node=kube_node)
    with open(inventories_path, 'w+') as f:
        f.write(content)


def main(inventories_path, local_inventory):
    inventory_data = load_inventory(local_inventory)
    hostvars = inventory_data['_meta']['hostvars']
    kube_node = inventory_data['kube_node']['hosts']
    kube_master = inventory_data['kube_master']['hosts']
    etcd = inventory_data['etcd']['hosts']

    create_inventory_file(inventories_path,
                          hostvars, kube_master, etcd, kube_node)


if __name__ == "__main__":
    path = yaml.load(sys.argv[1])
    local_inventory = yaml.load(sys.argv[2])

    main(path, local_inventory)
