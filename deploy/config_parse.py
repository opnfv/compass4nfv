##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import os
import netaddr
import yaml
import sys
import random
from Cheetah.Template import Template


def load_yaml(file):
    with open(file) as fd:
        return yaml.safe_load(fd)


def dump_yaml(data, file):
    with open(file, "w") as fd:
        yaml.safe_dump(data, fd, default_flow_style=False)


def mac_generator():
    def random_hex():
        return random.choice("0123456789ABCDEF")
    mac = "00:00"
    for i in xrange(4):
        mac += ":{0}{1}".format(random_hex(), random_hex())
    return mac


def export_env_dict(env_dict, output_path, direct=False):
    if not os.path.exists(output_path):
        raise IOError("output file: %s not exist" % output_path)
    if direct:
        for k, v in env_dict.items():
            os.system("echo 'export %s=\"%s\"' >> %s" %
                      (k, v, output_path))
    else:
        for k, v in env_dict.items():
            os.system("echo 'export %s=${%s:-%s}' >> %s" %
                      (k, k, v, output_path))


def decorator(func):
    def wrapter(s, seq=None):
        host_list = s.get('hosts', [])
        result = []
        for host in host_list:
            s = func(s, seq, host)
            if not s:
                continue
            result.append(s)
        if len(result) == 0:
            return ""
        elif seq:
            return "\"" + seq.join(result) + "\""
        else:
            return result
    return wrapter


@decorator
def hostnames(s, seq, host=None):
    return host.get('name', '')


@decorator
def hostroles(s, seq, host=None):
    return "%s=%s" % (host.get('name', ''), ','.join(host.get('roles', [])))


@decorator
def hostmachines(s, seq, host=None):
    return {'mac': host.get('interfaces', {}),
            'power_type': host.get('power_type', ''),
            'power_ip': host.get('power_ip', ''),
            'power_user': host.get('power_user', ''),
            'power_pass': host.get('power_pass', '')}


def export_network_file(dha, network, output_path):
    install_network_env = {}
    host_network_env = {}
    ip_settings = network['ip_settings']
    mgmt_net = [item for item in ip_settings
                if item['name'] == 'mgmt'][0]
    mgmt_gw = mgmt_net['gw']
    mgmt_cidr = mgmt_net['cidr']
    prefix = int(mgmt_cidr.split('/')[1])
    mgmt_netmask = '.'.join([str((0xffffffff << (32 - prefix) >> i) & 0xff)
                             for i in [24, 16, 8, 0]])
    dhcp_ip_range = ' '.join(mgmt_net['dhcp_ranges'][0])
    internal_vip = network['internal_vip']['ip']
    install_network_env.update({'INSTALL_GW': mgmt_gw})
    install_network_env.update({'INSTALL_CIDR': mgmt_cidr})
    install_network_env.update({'INSTALL_NETMASK': mgmt_netmask})
    install_network_env.update({'INSTALL_IP_RANGE': dhcp_ip_range})
    install_network_env.update({'VIP': internal_vip})
    export_env_dict(install_network_env, output_path)

    pxe_nic = os.environ['PXE_NIC']
    host_ip_range = mgmt_net['ip_ranges'][0]
    host_ips = netaddr.iter_iprange(host_ip_range[0], host_ip_range[1])
    host_networks = []
    for host in dha['hosts']:
        host_name = host['name']
        host_ip = str(host_ips.next())
        host_networks.append(
            '{0}:{1}={2}|is_mgmt'.format(host_name, pxe_nic, host_ip))
    host_subnets = [item['cidr'] for item in ip_settings]
    host_network_env.update({'NETWORK_MAPPING': "install=" + pxe_nic})
    host_network_env.update({'HOST_NETWORKS': ';'.join(host_networks)})
    host_network_env.update({'SUBNETS': ','.join(host_subnets)})
    export_env_dict(host_network_env, output_path, True)


def export_dha_file(dha, output_path, machine_path):
    env = {}
    env.update(dha)
    if env.get('hosts', []):
        env.pop('hosts')
    if 'plugins' in env:
        plugin_list = []
        for item in env.get('plugins'):
            plugin_str = ':'.join([item.keys()[0], item.values()[0]])
            plugin_list.append(plugin_str)
        env.update({'plugins': ','.join(plugin_list)})

    if 'cluster_param' in env:
        plugin_list = []
        for item in env.get('cluster_param'):
            plugin_str = ':'.join([item.keys()[0], item.values()[0]])
            plugin_list.append(plugin_str)
        env.update({'cluster_param': ','.join(plugin_list)})

    env.update({'CLUSTER_NAME': dha.get('NAME', "opnfv")})
    env.update({'TYPE': dha.get('TYPE', "virtual")})
    env.update({'FLAVOR': dha.get('FLAVOR', "cluster")})
    env.update({'HOSTNAMES': hostnames(dha, ',')})
    env.update({'HOST_ROLES': hostroles(dha, ';')})

    machine = []
    if dha.get('TYPE') == "virtual":
        virtual_mac = []
        for host in dha.get('hosts'):
            mac = mac_generator()
            machine.append({"mac": {"eth0": mac}, "power_type": "libvirt"})
            virtual_mac.append(mac)
        env.update({'HOST_MACS': ",".join(virtual_mac)})
    else:
        value = hostmachines(dha)
        for item in value:
            machine.append(item)
    dump_yaml(machine, machine_path)

    if dha.get('TYPE', "virtual") == "virtual":
        env.update({'VIRT_NUMBER': len(dha['hosts'])})

    export_env_dict(env, output_path)


def export_reset_file(dha, tmpl_dir, output_dir, output_path):
    tmpl_file_name = dha.get('POWER_TOOL', '')
    if not tmpl_file_name:
        return

    tmpl = Template(
        file=os.path.join(
            tmpl_dir,
            'power',
            tmpl_file_name +
            '.tmpl'),
        searchList=dha)

    reset_file_name = os.path.join(output_dir, tmpl_file_name + '.sh')
    with open(reset_file_name, 'w') as f:
        f.write(tmpl.respond())

    power_manage_env = {'POWER_MANAGE': reset_file_name}
    export_env_dict(power_manage_env, output_path, True)

if __name__ == "__main__":
    if len(sys.argv) != 7:
        print("parameter wrong %d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)

    _, dha_file, network_file, tmpl_dir, output_dir, output_file,\
        machine_file = sys.argv

    if not os.path.exists(dha_file):
        print("%s is not exist" % dha_file)
        sys.exit(1)

    output_path = os.path.join(output_dir, output_file)
    machine_path = os.path.join(output_dir, machine_file)
    os.system("touch %s" % output_path)
    os.system("echo \#config file deployment parameter > %s" % output_path)
    os.system("touch %s" % machine_path)

    dha_data = load_yaml(dha_file)
    network_data = load_yaml(network_file)

    export_dha_file(dha_data, output_path, machine_path)
    export_network_file(dha_data, network_data, output_path)
    export_reset_file(dha_data, tmpl_dir, output_dir, output_path)

    sys.exit(0)
