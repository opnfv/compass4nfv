##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import os
import sys
import yaml


def exec_cmd(cmd):
    print cmd
    os.system(cmd)


def create_bonding(network_info, rsa_file, compass_ip):
    for bond in network_info['bond_mappings']:
        bond_name = bond['name']
        host_name = bond.get('host')
        interfaces = bond.get('bond-slaves')
        bond_mode = bond['bond-mode']
        bond_miimon = bond['bond-miimon']
        lacp_rate = bond['bond-lacp_rate']
        xmit_hash_policy = bond['bond-xmit_hash_policy']
        bond_mtu = bond['mtu']
        if interfaces:
            for host in host_name:
                for interface in interfaces:
                    exec_cmd("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                              -i %s root@%s \
                              'cobbler system edit --name=%s --interface=%s --interface-type=bond_slave --interface-master=%s'"   # noqa
                             % (rsa_file, compass_ip, host, interface, bond_name))   # noqa

                exec_cmd("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
                          -i %s root@%s \
                          'cobbler system edit --name=%s --interface=%s --interface-type=bond --bonding-opts=\"miimon=%s mode=%s lacp_rate=%s xmit_hash_policy=%s mtu=%s\"'"   # noqa
                          % (rsa_file, compass_ip, host, bond_name, bond_miimon, bond_mode, lacp_rate, xmit_hash_policy, bond_mtu))   # noqa

if __name__ == "__main__":
    assert(len(sys.argv) == 4)
    create_bonding(
        yaml.safe_load(
            open(
                sys.argv[1])),
        sys.argv[2],
        sys.argv[3])
