##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import os
import sys
import yaml
import re
import subprocess
import traceback


def load_file(file):
    with open(file) as fd:
        try:
            return yaml.safe_load(fd)
        except:
            traceback.print_exc()
            return None


def dump_file(data, file):
    with open(file, 'w') as fd:
        try:
            return yaml.dump(data, fd, default_flow_style=False)
        except:
            traceback.print_exc()
            return None


def sync_openo_config(openo_config, dha, network):
    """sync opera/conf/open-o.yml according to DHA and Network file"""
    deploy_opts = dha.get('deploy_options')
    openo_net = network.get('openo_net')
    if deploy_opts['orchestrator']['type'] != 'open-o':
        print("orchestrator is not openo")
        sys.exit(1)

    openo_config['openo_version'] = deploy_opts['orchestrator']['version']
    openo_config['vnf_type'] = deploy_opts['vnf']['type']
    openo_config['openo_net']['openo_ip'] = openo_net['openo_ip']


def sync_admin_openrc(network, admin_openrc_file):
    ssh_opts = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    vip = network['public_vip']['ip']
    cmd = 'sshpass -p"root" ssh %s root@%s "cat /opt/admin-openrc.sh"' \
          % (ssh_opts, vip)
    ssh = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    if ssh.stdout is None:
        print("fetch openrc fail")
        sys.exit(1)

    rcdata = ssh.stdout.readlines()
    with open(admin_openrc_file, 'w') as fd:
        ip = re.compile("\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}")
        for i in rcdata:
            if 'OS_AUTH_URL' in i:
                i = re.sub(ip, vip, i)
            fd.write(i)

        fd.write('export OS_REGION_NAME=RegionOne')


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)

    _, dha_file, network_file = sys.argv
    compass_dir = os.getenv('COMPASS_DIR')

    if not compass_dir:
        print("env var COMPASS_DIR  doesn't exist")
        sys.exit(1)

    if not os.path.exists(dha_file):
        print("DHA file doesn't exist")
        sys.exit(1)
    if not os.path.exists(network_file):
        print("NETWORK file doesn't exist")
        sys.exit(1)

    dha = load_file(dha_file)
    network = load_file(network_file)

    if not dha:
        print('format error in DHA: %s' % dha_file)
        sys.exit(1)
    if not network:
        print('format error in NETWORK: %s' % network_file)
        sys.exit(1)

    work_dir = os.path.join(compass_dir, 'work')
    opera_dir = os.path.join(work_dir, 'opera')
    conf_dir = os.path.join(opera_dir, 'conf')
    openo_config_file = os.path.join(conf_dir, 'open-o.yml')
    admin_openrc_file = os.path.join(conf_dir, 'admin-openrc.sh')

    p1 = subprocess.Popen(
        "git clone https://gerrit.opnfv.org/gerrit/opera",
        cwd=work_dir, shell=True)
    p1.communicate()

    if not os.path.exists(openo_config_file):
        print('file opera/conf/open-o.yml not found')
        sys.exit(1)
    if not os.path.exists(admin_openrc_file):
        print('file opera/conf/admin-openrc.sh not found')
        sys.exit(1)

    openo_config = load_file(openo_config_file)
    sync_openo_config(openo_config, dha, network)
    dump_file(openo_config, openo_config_file)
    sync_admin_openrc(network, admin_openrc_file)

    p2 = subprocess.Popen("./opera_launch.sh", cwd=opera_dir, shell=True)
    p2.communicate()
    if p2.returncode != 0:
        print('./opera_launch.sh fail')
        sys.exit(1)
