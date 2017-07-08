#!/usr/bin/python
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import os
import yaml

if __name__ == "__main__":
    network_config_file = os.environ["NETWORK"]
    network_config = yaml.safe_load(open(network_config_file, "r"))
    os.system(
        "sudo ovs-vsctl --may-exist add-port br-external mgmt_vnic -- set Interface mgmt_vnic type=internal")   # noqa
    os.system("sudo ip addr flush mgmt_vnic")
    os.system("sudo ip link set mgmt_vnic up")
    for sys_intf in network_config["sys_intf_mappings"]:
        if sys_intf["name"] == "mgmt" and sys_intf.get("vlan_tag"):
            os.system(
                "sudo ovs-vsctl set port mgmt_vnic tag=%s" %
                sys_intf["vlan_tag"])

    for net_info in network_config["ip_settings"]:
        if net_info["name"] == "mgmt":
            mgmt_ip_range_end = net_info["ip_ranges"][0][1]
            mgmt_netmask = net_info["cidr"].split('/')[1]
            os.system(
                r"sudo ip addr add %s/%s dev mgmt_vnic" %
                (mgmt_ip_range_end, mgmt_netmask))
