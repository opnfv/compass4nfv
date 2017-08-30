##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import yaml
import sys
import subprocess

import log as logging

LOG = logging.getLogger("net-check")


def is_ip_reachable(ip):
    cmd = "ping -c 2 %s" % ip
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=None,
        shell=True)

    output = process.communicate()[0]
    if " 0% packet loss" in output:
        LOG.info("%s is reachable", ip)
    elif "100% packet loss" in output:
        LOG.error("%s is unreachable" % (ip))
        return False
    else:
        LOG.warn("%r", output)

    return True


def is_host_ips_reachable(settings):
    external = settings["external"]["ip"]
    external_gw = settings["external"]["gw"]
    # storage = settings["storage"]["ip"]
    mgmt = settings["mgmt"]["ip"]

    return is_ip_reachable(external) \
        and is_ip_reachable(external_gw) \
        and is_ip_reachable(mgmt)


def main(hostname, config):
    LOG.info("host is %s", hostname)

    result = True

    for host, settings in config.iteritems():
        LOG.info("check %s network connectivity start", host)
        result = result and is_host_ips_reachable(settings)

    if result:
        LOG.info("All hosts ips are reachable")
    else:
        LOG.error("Some hosts ips are unreachable !!!")
        sys.exit(-1)

if __name__ == "__main__":
    hostname = yaml.load(sys.argv[1])
    config = yaml.load(sys.argv[2])
    config.pop(hostname, None)

    main(hostname, config)
