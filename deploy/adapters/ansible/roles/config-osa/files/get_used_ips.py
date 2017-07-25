#!/usr/bin/env python

import netaddr
import sys

def print_to_ansible(used_ips):
    res = []
    for item in used_ips:
        res.append(item[0] + ',' + item[1])
    return '|'.join(res)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("parameter error: %s" % sys.argv)
        sys.exit(1)

    cidr = sys.argv[1]
    ip_start = sys.argv[2]
    ip_end = sys.argv[3]

    try:
        ips = netaddr.IPNetwork(cidr)
        unused_ip_start = netaddr.IPNetwork(ip_start)
        unused_ip_end = netaddr.IPNetwork(ip_end)
    except Exception as err:
        print err
        sys.exit(1)

    if unused_ip_start > unused_ip_end:
        unused_ip_start, unused_ip_end = unused_ip_end, unused_ip_start

    ip_start = netaddr.IPNetwork(ips[1])
    ip_end = netaddr.IPNetwork(ips[-2])
    used_ips = []
    used_ips.append([str(ip_start.ip), str(unused_ip_start.next(-1).ip)])
    used_ips.append([str(unused_ip_end.next(1).ip), str(ip_end.ip)])
    if unused_ip_start == ip_start:
        used_ips.remove(used_ips[0])
    if unused_ip_end == ip_end:
        used_ips.remove(used_ips[1])

    sys.stdout.write(print_to_ansible(used_ips))
    sys.stdout.flush()
