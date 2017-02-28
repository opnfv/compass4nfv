import yaml
import sys
from jinja2 import Environment

INVENTORY_TEMPLATE = """
[all]
{% for host, ip in hosts.iteritems() %}
{{ host }} ansible_ssh_host={{ ip }}
{% endfor %}
[kube-master]
host1
host2

[etcd]
host1
host2
host3

[kube-node]
host2
host3
host4
host5

[k8s-cluster:children]
kube-node
kube-master

[calico-rr]
[vault]
"""


def create_inventory_file(inventories_path, hosts):
    content = Environment().from_string(INVENTORY_TEMPLATE).render(hosts=hosts)
    with open(inventories_path, 'w+') as f:
        f.write(content)


def fetch_all_sorted_external_ip(ip_cfg):
    hosts = {}
    for host, settings in ip_cfg.iteritems():
        external = settings["br-prv"]["ip"]
        hosts[host] = external
    return hosts


def main(inventories_path, ip_cfg):
    hosts = fetch_all_sorted_external_ip(ip_cfg)
    create_inventory_file(inventories_path, hosts)


if __name__ == "__main__":
    path = yaml.load(sys.argv[1])
    ipv_cfg = yaml.load(sys.argv[2])

    main(path, ipv_cfg)
