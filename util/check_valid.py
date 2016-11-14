import re
import os
import yaml
import sys
import traceback


def init(file):
    with open(file) as fd:
        try:
            return yaml.load(fd)
        except:
            traceback.print_exc()
            return None


def err_print(info):
    print '\033[0;31m%s\033[0m' % info


def check_ip(ip):
    if not ip:
        return False
    res = re.search(
        "^(0?\d{1,2}|1\d\d|2[0-4]\d|25[0-5])(\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])){3}(\/(\d|[1-2]\d|3[0-2]))?$",  # noqa
        ip) is not None
    return res


def check_mac(mac):
    if not mac:
        return False
    res = re.search("^([a-zA-Z0-9]{2}:){5}[a-zA-Z0-9]{2}$", mac) is not None
    return res


def check_network(network):
    for i in network.get('ip_settings'):
        if not (check_ip(i['cidr']) and check_ip(
                i['ip_ranges'][0][0]) and check_ip(i['ip_ranges'][0][1])):
            return False
        if i['name'] == 'external' and not check_ip(i['gw']):
            return False

    if not check_ip(network['internal_vip']['ip']):
        return False

    if not check_ip(network['public_vip']['ip']):
        return False

    if not check_ip(network['public_net_info']['external_gw']):
        return False

    if not check_ip(network['public_net_info']['floating_ip_cidr']):
        return False

    if not check_ip(network['public_net_info']['floating_ip_start']):
        return False

    if not check_ip(network['public_net_info']['floating_ip_end']):
        return False

    return True


def check_dha(dha):
    if dha['TYPE'] == 'baremetal':
        for i in dha['hosts']:
            if not (check_mac(i['mac']) and check_mac(
                    i['interfaces'][0]['eth1']) and check_ip(i['ipmiIp'])):
                return False
    return True

if __name__ == "__main__":
    flag = 0

    if len(sys.argv) != 3:
        err_print('input file error')
        sys.exit(1)

    _, dha_file, network_file = sys.argv

    if not os.path.exists(dha_file):
        sys.exit(1)
    else:
        dha = init(dha_file)
        if not dha:
            err_print('format error in DHA')
        else:
            if not check_dha(dha):
                err_print('invalid address in DHA')
                flag = 1

    if not os.path.exists(network_file):
        sys.exit(1)
    else:
        network = init(network_file)
        if not network:
            err_print('format error in NETWORK')
        else:
            if not check_network(network):
                err_print('invalid address in NETWORK')
                flag = 1

    if flag == 1:
        sys.exit(1)
