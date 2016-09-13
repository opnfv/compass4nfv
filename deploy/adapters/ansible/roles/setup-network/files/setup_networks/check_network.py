import yaml
import sys
import subprocess

import log as logging

LOG = logging.getLogger("net-check")

def is_ip_reachable(ip):
    cmd = "ping -c 1 %s" % ip
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None, shell=True)

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
    result = True

    external = settings["br-prv"]["ip"]
    result = result and is_ip_reachable(external)

    external_gw = settings["br-prv"]["gw"]
    result = result and is_ip_reachable(external_gw)

    storage = settings["storage"]["ip"]
    result = result and is_ip_reachable(storage)

    mgmt = settings["mgmt"]["ip"]
    result = result and is_ip_reachable(mgmt)

    return result

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

