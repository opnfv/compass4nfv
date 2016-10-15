import re
import os
import yaml
import sys
import traceback

def init(file):
    with open (file) as fd:
        try:
            return yaml.load(fd)
        except:
            traceback.print_exc()
            return None

def err_print(info):
    print '\033[0;31m%s\033[0m' %info

def check_ip(ip):
    if not ip:
        return False
    res=re.search("^(0?\d{1,2}|1\d\d|2[0-4]\d|25[0-5])(\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])){3}(\/(\d|[1-2]\d|3[0-2]))?$",ip)!=None
    return res

def check_mac(mac):
    if not mac:
        return False
    res=re.search("^([a-zA-Z0-9]{2}:){5}[a-zA-Z0-9]{2}$",mac)!=None
    return res

def check_network(network):
    invalid = 0
    for i in network['ip_settings']:
        if not check_ip(i['cidr']):
            err_print('''invalid address:
                ip_settings:
                  - name: %s
                    cidr: %s''' %(i['name'],i['cidr']))
            invalid = 1
        if not check_ip(i['ip_ranges'][0][0]):
            err_print('''invalid address:
                ip_settings:
                 - name: %s
                   ip_ranges:
                   - - %s''' %(i['name'],i['ip_ranges'][0][0]))
            invalid = 1
        if not check_ip(i['ip_ranges'][0][1]):
            err_print('''invalid address:
                ip_settings:
                    - name:  %s
                    ip_ranges:
                    - %s''' %(i,i['ip_ranges'][0][1]))
            invalid = 1
        if i['name'] == 'external' and not check_ip(i['gw']):
            err_print('''invalid address:
                ip_settings:
                    - name: %s
                    gw: %s''' %(i['name'],i['gw']))
            invalid = 1

    for i in network['public_net_info'].keys():
        if i in ('external_gw', 'floating_ip_cidr', 'floating_ip_start', 'floating_ip_end'):
            if not check_ip(network['public_net_info'][i]):
                err_print('''invalid address:
                public_net_info:
                  %s: %s''' %(i,network['public_net_info'][i]))
                invalid = 1
    
    if invalid == 0:
        return True
    else:
        return False

def check_dha(dha):
    invalid = 0
    if dha['TYPE'] == 'baremetal':
        for i in dha['hosts']:
            if not check_mac(i['mac']):
                err_print('''invalid address:
                hosts:
                 - name: %s
                   mac: %s''' %(i['name'],i['mac']))
                invalid = 1
            if not check_mac(i['interfaces'][0]['eth1']):
                err_print('''invalid address:
                hosts:
                 - name: %s
                   interfaces:
                    - eth1: %s''' %(i['name'],i['interfaces'][0]['eth1']))
                invalid = 1
            if not check_ip(i['ipmiIp']):
                err_print('''invalid address:
                hosts:
                 - name: %s
                   ipmiIp: %s''' %(i['name'],i['ipmiIp']))
                invalid = 1

    if invalid == 0:
        return True
    else:
        return False

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
            err_print('format error in DHA: %s' %dha_file)
        else:
            if not check_dha(dha):
                err_print('in DHA: %s' %dha_file)
                flag = 1

    if not os.path.exists(network_file):
        sys.exit(1)
    else:
        network = init(network_file)
        if not network:
            err_print('format error in NETWORK: %s' %network_file)
        else:
            if not check_network(network):
                err_print('in NETWORK: %s' %network_file)
                flag = 1

    if flag == 1:
        sys.exit(1)
