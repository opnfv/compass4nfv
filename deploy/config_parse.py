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
from Cheetah.Template import Template

PXE_INTF = "eth0"


def init(file):
    with open(file) as fd:
        return yaml.safe_load(fd)


def export_env_dict(env_dict, ofile, direct=False):
    if not os.path.exists(ofile):
        raise IOError("output file: %s not exist" % ofile)
    if direct:
        for k, v in env_dict.items():
            os.system("echo 'export %s=\"%s\"' >> %s" % (k, v, ofile))
    else:
        for k, v in env_dict.items():
            os.system("echo 'export %s=${%s:-%s}' >> %s" % (k, k, v, ofile))


def decorator(func):
    def wrapter(s, seq):
        host_list = s.get('hosts', [])
        result = []
        for host in host_list:
            s = func(s, seq, host)
            if not s:
                continue
            result.append(s)
        if len(result) == 0:
            return ""
        else:
            return "\"" + seq.join(result) + "\""
    return wrapter


@decorator
def hostnames(s, seq, host=None):
    return host.get('name', '')


@decorator
def hostroles(s, seq, host=None):
    return "%s=%s" % (host.get('name', ''), ','.join(host.get('roles', [])))


@decorator
def hostmacs(s, seq, host=None):
    return host.get('mac', '')


def export_network_file(dha, network, ofile):
    env = {}

    mgmt_net = [item for item in network['ip_settings']
                if item['name'] == 'mgmt'][0]
    mgmt_gw = mgmt_net['gw']
    mgmt_cidr = mgmt_net['cidr']
    prefix = int(mgmt_cidr.split('/')[1])
    mgmt_netmask = '.'.join([str((0xffffffff << (32 - prefix) >> i) & 0xff)
                             for i in [24, 16, 8, 0]])
    dhcp_ip_range = ' '.join(mgmt_net['dhcp_ranges'][0])
    env.update({'INSTALL_GW': mgmt_gw})
    env.update({'INSTALL_CIDR': mgmt_cidr})
    env.update({'INSTALL_NETMASK': mgmt_netmask})
    env.update({'INSTALL_IP_RANGE': dhcp_ip_range})
    export_env_dict(env, ofile)

    host_ip_range = mgmt_net['ip_ranges'][0]
    host_ips = netaddr.iter_iprange(host_ip_range[0], host_ip_range[1])
    host_networks = []
    for host in dha['hosts']:
        host_name = host['name']
        host_ip = str(host_ips.next())
        host_networks.append(
            "{0}:{1}={2}|is_mgmt".format(host_name, PXE_INTF, host_ip))
    host_network_env = {"HOST_NETWORKS": ';'.join(host_networks)}
    export_env_dict(host_network_env, ofile, True)


def export_dha_file(dha, dha_file, ofile):
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

    env.update({'TYPE': dha.get('TYPE', "virtual")})
    env.update({'FLAVOR': dha.get('FLAVOR', "cluster")})
    env.update({'HOSTNAMES': hostnames(dha, ',')})
    env.update({'HOST_ROLES': hostroles(dha, ';')})
    env.update({'DHA': dha_file})

    value = hostmacs(dha, ',')
    if len(value) > 0:
        env.update({'HOST_MACS': value})

    export_env_dict(env, ofile)


def export_reset_file(dha, tmpl_dir, output_dir, ofile):
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
    export_env_dict(power_manage_env, ofile, True)

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)

    _, dha_file, network_file, tmpl_dir, output_dir, output_file = sys.argv

    if not os.path.exists(dha_file):
        print("%s is not exist" % dha_file)
        sys.exit(1)

    ofile = os.path.join(output_dir, output_file)
    os.system("touch %s" % ofile)
    os.system("echo \#config file deployment parameter > %s" % ofile)

    dha_data = init(dha_file)
    network_data = init(network_file)

    export_dha_file(dha_data, dha_file, ofile)
    export_network_file(dha_data, network_data, ofile)
    export_reset_file(dha_data, tmpl_dir, output_dir, ofile)

    sys.exit(0)
