##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import re
import os
import yaml
import sys
import traceback


def load_file(file):
    with open(file) as fd:
        try:
            return yaml.safe_load(fd)
        except:
            traceback.print_exc()
            return None


def err_print(info):
    print '\033[0;31m%s\033[0m' % info


def is_valid_ip(ip):
    """return True if the given string is a well-formed IP address
       currently only support IPv4
    """
    if not ip:
        return False
    res = re.search(
        "^(0?\d{1,2}|1\d\d|2[0-4]\d|25[0-5])(\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])){3}(\/(\d|[1-2]\d|3[0-2]))?$",  # noqa
        ip) is not None
    return res


def is_valid_mac(mac):
    """return True if the given string is a well-formed MAC address
    """
    if not mac:
        return False
    res = re.search("^([a-zA-Z0-9]{2}:){5}[a-zA-Z0-9]{2}$", mac) is not None
    return res


def check_network_file(network):
    invalid = False
    for i in network['ip_settings']:
        if not is_valid_ip(i['cidr']):
            err_print('''invalid address:
                ip_settings:
                  - name: %s
                    cidr: %s''' % (i['name'], i['cidr']))
            invalid = True
        if not is_valid_ip(i['ip_ranges'][0][0]):
            err_print('''invalid address:
                ip_settings:
                  - name: %s
                    ip_ranges:
                    - - %s''' % (i['name'], i['ip_ranges'][0][0]))
            invalid = True
        if not is_valid_ip(i['ip_ranges'][0][1]):
            err_print('''invalid address:
                ip_settings:
                  - name: %s
                    ip_ranges:
                    - %s''' % (i['name'], i['ip_ranges'][0][1]))
            invalid = True
        if i['name'] == 'external' and not is_valid_ip(i['gw']):
            err_print(i['gw'])
            err_print('''invalid address:
                ip_settings:
                  - name: %s
                    gw: %s''' % (i['name'], i['gw']))
            invalid = True

    for i in network['public_net_info'].keys():
        if i in ('external_gw', 'floating_ip_cidr',
                 'floating_ip_start', 'floating_ip_end'):
            if not is_valid_ip(network['public_net_info'][i]):
                err_print('''invalid address:
                public_net_info:
                  %s: %s''' % (i, network['public_net_info'][i]))
                invalid = True

    if not invalid:
        return True
    else:
        return False


def check_dha_file(dha):
    invalid = False
    if dha['TYPE'] == 'baremetal':
        for i in dha['hosts']:
            for j in i['interfaces']:
                if not is_valid_mac(i['interfaces'].get(j)):
                    err_print('''invalid address:
                    hosts:
                        - name: %s
                          interfaces:
                            - %s: %s''' % (i['name'], j, i['interfaces'].get(j)))  # noqa: E501
                    invalid = True
            if not is_valid_ip(i['power_ip']):
                err_print('''invalid address:
                hosts:
                 - name: %s
                   power_ip: %s''' % (i['name'], i['power_ip']))
                invalid = True

    if not invalid:
        return True
    else:
        return False

if __name__ == "__main__":

    has_invalid = False

    if len(sys.argv) != 3:
        err_print('input file error')
        sys.exit(1)

    _, dha_file, network_file = sys.argv

    if not os.path.exists(dha_file):
        err_print("DHA file doesn't exist")
        sys.exit(1)
    else:
        dha = load_file(dha_file)
        if not dha:
            err_print('format error in DHA: %s' % dha_file)
            has_invalid = True
        else:
            if not check_dha_file(dha):
                err_print('in DHA: %s' % dha_file)
                has_invalid = True

    if not os.path.exists(network_file):
        err_print("NETWORK file doesn't exist")
        sys.exit(1)
    else:
        network = load_file(network_file)
        if not network:
            err_print('format error in NETWORK: %s' % network_file)
            has_invalid = True
        else:
            if not check_network_file(network):
                err_print('in NETWORK: %s' % network_file)
                has_invalid = True

    if has_invalid:
        sys.exit(1)
