.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Installation Guide (Bare Metal Deployment)
==========================================

Nodes Configuration (Bare Metal Deployment)
-------------------------------------------

The below file is the inventory template of deployment nodes:

"compass4nfv/deploy/conf/hardware_environment/huawei-pod1/dha.yml"

You can write your own IPMI IP/User/Password/Mac address/roles reference to it.

        - name -- Host name for deployment node after installation.

        - ipmiVer -- IPMI interface version for deployment node support. IPMI 1.0
          or IPMI 2.0 is available.

        - ipmiIP -- IPMI IP address for deployment node. Make sure it can access
          from Jumphost.

        - ipmiUser -- IPMI Username for deployment node.

        - ipmiPass -- IPMI Password for deployment node.

        - mac -- MAC Address of deployment node PXE NIC .

        - roles -- Components deployed.


**Assignment of different roles to servers**

E.g. Openstack only deployment roles setting

.. code-block:: yaml

    TYPE: baremetal
    FLAVOR: cluster
    POWER_TOOL: ipmitool

    ipmiUser: root
    ipmiVer: '2.0'

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
        ipmiPass: Huawei@123
        roles:
          - controller
          - ha

      - name: host2
        mac: 'D8:49:0B:DA:5A:B7'
        interfaces:
          - eth1: 'D8:49:0B:DA:5A:B8'
        ipmiIp: 172.16.130.27
        ipmiPass: huawei@123
        roles:
          - compute

NOTE:
IF YOU SELECT MUTIPLE NODES AS CONTROLLER, THE 'ha' role MUST BE SELECT, TOO.

E.g. Openstack and ceph deployment roles setting

.. code-block:: yaml

    TYPE: baremetal
    FLAVOR: cluster
    POWER_TOOL: ipmitool

    ipmiUser: root
    ipmiVer: '2.0'

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
        ipmiPass: Huawei@123
        roles:
          - controller
          - ha
          - ceph-adm
          - ceph-mon

      - name: host2
        mac: 'D8:49:0B:DA:5A:B7'
        interfaces:
          - eth1: 'D8:49:0B:DA:5A:B8'
        ipmiIp: 172.16.130.27
        ipmiPass: huawei@123
        roles:
          - compute
          - ceph-osd

E.g. Openstack and ODL deployment roles setting

.. code-block:: yaml

    TYPE: baremetal
    FLAVOR: cluster
    POWER_TOOL: ipmitool

    ipmiUser: root
    ipmiVer: '2.0'

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
        ipmiPass: Huawei@123
        roles:
          - controller
          - ha
          - odl

      - name: host2
        mac: 'D8:49:0B:DA:5A:B7'
        interfaces:
          - eth1: 'D8:49:0B:DA:5A:B8'
        ipmiIp: 172.16.130.27
        ipmiPass: huawei@123
        roles:
          - compute

E.g. Openstack and ONOS deployment roles setting

.. code-block:: yaml

    TYPE: baremetal
    FLAVOR: cluster
    POWER_TOOL: ipmitool

    ipmiUser: root
    ipmiVer: '2.0'

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
        ipmiPass: Huawei@123
        roles:
          - controller
          - ha
          - onos

      - name: host2
        mac: 'D8:49:0B:DA:5A:B7'
        interfaces:
          - eth1: 'D8:49:0B:DA:5A:B8'
        ipmiIp: 172.16.130.27
        ipmiPass: huawei@123
        roles:
          - compute

Network Configuration (Bare Metal Deployment)
---------------------------------------------

Before deployment, there are some network configuration to be checked based
on your network topology.Compass4nfv network default configuration file is
"compass4nfv/deploy/conf/hardware_environment/huawei-pod1/network.yml".
You can write your own reference to it.

**The following figure shows the default network configuration.**

.. code-block:: console


      +--+                          +--+     +--+
      |  |                          |  |     |  |
      |  |      +------------+      |  |     |  |
      |  +------+  Jumphost  +------+  |     |  |
      |  |      +------+-----+      |  |     |  |
      |  |             |            |  |     |  |
      |  |             +------------+  +-----+  |
      |  |                          |  |     |  |
      |  |      +------------+      |  |     |  |
      |  +------+    host1   +------+  |     |  |
      |  |      +------+-----+      |  |     |  |
      |  |             |            |  |     |  |
      |  |             +------------+  +-----+  |
      |  |                          |  |     |  |
      |  |      +------------+      |  |     |  |
      |  +------+    host2   +------+  |     |  |
      |  |      +------+-----+      |  |     |  |
      |  |             |            |  |     |  |
      |  |             +------------+  +-----+  |
      |  |                          |  |     |  |
      |  |      +------------+      |  |     |  |
      |  +------+    host3   +------+  |     |  |
      |  |      +------+-----+      |  |     |  |
      |  |             |            |  |     |  |
      |  |             +------------+  +-----+  |
      |  |                          |  |     |  |
      |  |                          |  |     |  |
      +-++                          ++-+     +-++
        ^                            ^         ^
        |                            |         |
        |                            |         |
      +-+-------------------------+  |         |
      |      External Network     |  |         |
      +---------------------------+  |         |
             +-----------------------+---+     |
             |       IPMI Network        |     |
             +---------------------------+     |
                     +-------------------------+-+
                     | PXE(Installation) Network |
                     +---------------------------+


Start Deployment (Bare Metal Deployment)
----------------------------------------

1. Edit run.sh

Set OS version and OpenStack version for deployment nodes.
    Compass4nfv Colorado supports three OS version based openstack mitaka.

E.g.
.. code-block:: bash

    ########## Ubuntu14.04 Mitaka ##########
    export OS_VERSION=trusty
    export OPENSTACK_VERSION=mitaka

    ########## Ubuntu16.04 Mitaka ##########
    # export OS_VERSION=xenial
    # export OPENSTACK_VERSION=mitaka_xenial

    ########## Centos7 Mitaka ##########
    # export OS_VERSION=centos7
    # export OPENSTACK_VERSION=mitaka

Set ISO image that you want to deploy

E.g.

.. code-block:: bash

    # YOUR_ISO is your iso's absolute path
    export YOUR_ISO=file:///home/compass/compass4nfv.iso
    # or
    # export YOUR_ISO=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

Set PXE/Installation NIC for Jumphost. (set eth1 E.g.)

E.g.

.. code-block:: bash

    ########## Hardware_Deploy Jumpserver_NIC ##########
    export INSTALL_NIC=eth1

Set scenario that you want to deploy

E.g.

nosdn-nofeature scenario deploy sample

.. code-block:: bash

    # YOUR_DHA is your dha.yml's path
    export YOUR_DHA=./deploy/conf/hardware_environment/huawei-pod1/os-nosdn-nofeature-ha.yml

    # YOUR_NETWORK is your network.yml's path
    export YOUR_NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

ocl-nofeature scenario deploy sample

.. code-block:: bash

    # YOUR_DHA is your dha.yml's path
    export YOUR_DHA=./deploy/conf/hardware_environment/huawei-pod1/os-ocl-nofeature-ha.yml

    # YOUR_NETWORK is your network.yml's path
    export YOUR_NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network_ocl.yml

odl_l2-moon scenario deploy sample

.. code-block:: bash

    # YOUR_DHA is your dha.yml's path
    export YOUR_DHA=./deploy/conf/hardware_environment/huawei-pod1/os-odl_l2-moon-ha.yml

    # YOUR_NETWORK is your network.yml's path
    export YOUR_NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

 odl_l2-nofeature scenario deploy template

.. code-block:: bash

    # YOUR_DHA is your dha.yml's path
    export YOUR_DHA=./deploy/conf/hardware_environment/huawei-pod1/os-odl_l2-nofeature-ha.yml

    # YOUR_NETWORK is your network.yml's path
    export YOUR_NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

odl_l3-nofeature scenario deploy sample

.. code-block:: bash

    # YOUR_DHA is your dha.yml's path
    export YOUR_DHA=./deploy/conf/hardware_environment/huawei-pod1/os-odl_l3-nofeature-ha.yml

    # YOUR_NETWORK is your network.yml's path
    export YOUR_NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

onos-nofeature scenario deploy sample

.. code-block:: bash

    # YOUR_DHA is your dha.yml's path
    export YOUR_DHA=./deploy/conf/hardware_environment/huawei-pod1/os-onos-nofeature-ha.yml

    # YOUR_NETWORK is your network.yml's path
    export YOUR_NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network_onos.yml

onos-sfc deploy scenario sample

.. code-block:: bash

    # YOUR_DHA is your dha.yml's path
    export YOUR_DHA=./deploy/conf/hardware_environment/huawei-pod1/os-onos-sfc-ha.yml

    # YOUR_NETWORK is your network.yml's path
    export YOUR_NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network_onos.yml

2. Run ``run.sh``

.. code-block:: bash

    ./run.sh

