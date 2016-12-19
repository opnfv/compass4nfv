.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Installation Guide (Bare Metal Deployment)
==========================================

Nodes Configuration (Bare Metal Deployment)
-------------------------------------------

The below file is the inventory template of deployment nodes:

"compass4nfv/deploy/conf/hardware_environment/huawei-pod1/dha.yml"

The "dha.yml" is a collectively name for "os-nosdn-nofeature-ha.yml
os-ocl-nofeature-ha.yml os-odl_l2-moon-ha.yml etc".

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

**Set TYPE/FLAVOR and POWER TOOL**

E.g.
.. code-block:: yaml

    TYPE: baremetal
    FLAVOR: cluster
    POWER_TOOL: ipmitool

**Set ipmiUser/ipmiPass and ipmiVer**

E.g.

.. code-block:: yaml

    ipmiUser: USER
    ipmiPass: PASSWORD
    ipmiVer: '2.0'

**Assignment of different roles to servers**

E.g. Openstack only deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
        roles:
          - controller
          - ha

      - name: host2
        mac: 'D8:49:0B:DA:5A:B7'
        interfaces:
          - eth1: 'D8:49:0B:DA:5A:B8'
        ipmiIp: 172.16.130.27
        roles:
          - compute

NOTE:
IF YOU SELECT MUTIPLE NODES AS CONTROLLER, THE 'ha' role MUST BE SELECT, TOO.

E.g. Openstack and ceph deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
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
        roles:
          - compute
          - ceph-osd

E.g. Openstack and ODL deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
        roles:
          - controller
          - ha
          - odl

      - name: host2
        mac: 'D8:49:0B:DA:5A:B7'
        interfaces:
          - eth1: 'D8:49:0B:DA:5A:B8'
        ipmiIp: 172.16.130.27
        roles:
          - compute

E.g. Openstack and ONOS deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        mac: 'F8:4A:BF:55:A2:8D'
        interfaces:
           - eth1: 'F8:4A:BF:55:A2:8E'
        ipmiIp: 172.16.130.26
        roles:
          - controller
          - ha
          - onos

      - name: host2
        mac: 'D8:49:0B:DA:5A:B7'
        interfaces:
          - eth1: 'D8:49:0B:DA:5A:B8'
        ipmiIp: 172.16.130.27
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

1. Edit deploy.sh

Set OS version and OpenStack version for deployment nodes.
    Compass4nfv Colorado supports three OS version based openstack mitaka.

E.g.

.. code-block:: bash

    ######################### The environment for Openstack ######################
    # Ubuntu16.04 Newton
    #export OS_VERSION=xenial
    #export OPENSTACK_VERSION=newton

    # Centos7 Newton
    #export OS_VERSION=centos7
    #export OPENSTACK_VERSION=newton

Set ISO image that you want to deploy

E.g.

.. code-block:: bash

    # ISO_URL is your iso's absolute path
    export ISO_URL=file:///home/compass/compass4nfv.iso
    # or
    # export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

Set Jumphost PXE NIC. (set eth1 E.g.)

E.g.

.. code-block:: bash

    ########## Hardware Deploy Jumphost PXE NIC ##########
    # you need comment out it when virtual deploy
    export INSTALL_NIC=eth1

Set scenario that you want to deploy

E.g.

nosdn-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/huawei-pod1/os-nosdn-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

ocl-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/huawei-pod1/os-ocl-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network_ocl.yml

odl_l2-moon scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/huawei-pod1/os-odl_l2-moon-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

odl_l2-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/huawei-pod1/os-odl_l2-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

odl_l3-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/huawei-pod1/os-odl_l3-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

onos-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/huawei-pod1/os-onos-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network_onos.yml

onos-sfc deploy scenario sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/huawei-pod1/os-onos-sfc-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network_onos.yml

2. Run ``deploy.sh``

.. code-block:: bash

    ./deploy.sh
