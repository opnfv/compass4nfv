.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0

Configure network
=================
network_cfg.yaml file describes networks configuration for openstack on hosts. It
specifies host network mapping and ip assignment of networks to be installed on hosts.
Compass4nfv includes a sample network_cfg.yaml under
``compass4nfv/deploy/conf/network_cfg.yaml``

There are three openstack networks to be installed: external, mgmt and storage. These
three networks can be shared on one physical nic or on separate nics (multi-nic). The
sample included in compass4nfv uses one nic. For multi-nic configuration, see multi-nic
configuration.

Configure openstack network
---------------------------

****! All interface name in network_cfg.yaml must be identified in dha file by mac address !****

Compass4nfv will install networks on host as described in this configuration. It will look
for physical nic on host by **mac address** from dha file and rename nic to the name with
that mac address. Therefore, any network interface name that is not identified by mac
address in dha file will not be installed correctly as compass4nfv cannot find the nic.

**Configure provider network**

.. code-block:: yaml

 provider_net_mappings:
   - name: br-prv
     network: physnet
     interface: eth1
     type: ovs
     role:
       - controller
       - compute

The external nic in dha file must be named ``eth1`` with mac address. If user uses a
different interface name in dha file, change ``eth1`` to that name here.
Note: User cannot use eth0 for external interface name as install/pxe network is named as
such.

**Configure openstack mgmt&storage network**:

.. code-block:: yaml

 sys_intf_mappings:
   - name: mgmt
     interface: eth1
     vlan_tag: 101
     type: vlan
     role:
       - controller
       - compute
 - name: storage
     interface: eth1
     vlan_tag: 102
     type: vlan
     role:
       - controller
       - compute

Change ``vlan_tag`` of ``mgmt`` and ``storage`` to corresponding vlan tag configured on
switch.

**Note**: for virtual deployment, there is no need to modify mgmt&storage network.

If using multi-nic feature, i.e, separate nic for mgmt or storage network, user needs to
change ``name`` to desired nic name (need to match dha file). Please see multi-nic
configuration.

Assign IP address to networks
-----------------------------------------

``ip_settings`` section specifics ip assignment for openstack networks.

User can use default ip range for mgmt&storage network.

for external networks:

.. code-block:: yaml

 - name: external
    ip_ranges:
    - - "192.168.50.210"
      - "192.168.50.220"
    cidr: "192.168.50.0/24"
    gw: "192.168.50.1"
    role:
      - controller
      - compute

Provide at least number of hosts available ip for external IP range(these ips will be
assigned to each host). Provide actual cidr and gateway in ``cidr``  and ``gw``  fields.

**configure public IP for horizon dashboard**

.. code-block:: yaml

 public_vip:
  ip: 192.168.50.240
  netmask: "24"
  interface: external

Provide an external ip in ``ip`` field. This ip cannot be within the ip range assigned to
external network configured in pervious section. It will be used for horizon address.

See section 6.2 (Vitual) and 7.2 (BareMetal) for graphs illustrating network topology.

