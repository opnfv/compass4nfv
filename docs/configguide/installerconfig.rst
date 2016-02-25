.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Compass4nfv configuration
=========================

This document describes providing guidelines on how to install and
configure the Brahmaputra release of OPNFV when using Compass as a
deployment tool including required software and hardware
configurations.

Installation and configuration of host OS, OpenStack, OpenDaylight,
ONOS, Ceph etc. can be supported by Compass on VMs or Bare Metal
nodes.

The audience of this document is assumed to have good knowledge in
networking and Unix/Linux administration.

-------------
Preconditions
-------------

Before starting the installation of the Brahmaputra release of OPNFV,
some planning must be done.


Retrieving the installation ISO image
-------------------------------------

First of all, The installation ISO is needed for deploying your OPNFV
environment, it included packages of Compass, OpenStack, OpenDaylight, ONOS
and so on.

The stable release ISO can be retrieved via `OPNFV offical software download link <https://www.opnfv.org/software/>`_

The daily build ISO can be retrieved via OPNFV artifacts repository:

http://artifacts.opnfv.org/

NOTE: Search the keyword "Compass4nfv/Brahmaputra" to locate the ISO image.

E.g.
compass4nfv/brahmaputra/opnfv-2016-01-16_15-03-18.iso
compass4nfv/brahmaputra/opnfv-2016-01-16_15-03-18.properties

The name of iso image includes the time of iso building, you can get the daily
ISO according the building time.
The git url and sha1 of Compass4nfv are recorded in properties files,
According these, the corresponding deployment scripts can be retrieved.


Getting the deployment scripts
------------------------------

To retrieve the repository of Compass4nfv on Jumphost use the following command:

- git clone https://gerrit.opnfv.org/gerrit/compass4nfv

To get stable/brahmaputra release use the following command:

- git checkout brahmaputra.1.0

NOTE: PLEASE DO NOT GIT CLONE COMPASS4NFV IN root DIRECTORY.

If you don't have a Linux foundation user id, get your own by the url:

https://wiki.opnfv.org/developer/getting_started

If you want to use a daily release ISO, please set the branch to the corresponding
deployment scripts:

E.g.
Git sha1 in file "opnfv-2016-01-16_15-03-18.properties" is
d5a13ce7cc2ce89946d34b0402ecf33c1d291851

- git checkout d5a13ce7cc2ce89946d34b0402ecf33c1d291851


Preparing the installation environment
--------------------------------------

If you have only 1 Bare Metal server, Virtual deployment is recommended. if more
than or equal 3 servers, the Bare Metal deployment is recommended. The minimum number of
servers for Bare metal deployment is 3, 1 for JumpServer(Jumphost), 1 for controller,
1 for compute.

------------------
Setup Requirements
------------------

Jumphost Requirements
---------------------

The Jumphost requirements are outlined below:

1.     Ubuntu 14.04 (Pre-installed).

2.     Root access.

3.     libvirt virtualization support.

4.     Minimum 2 NICs.

       -  PXE installation Network (Receiving PXE request from nodes and providing OS provisioning)

       -  IPMI Network (Nodes power control and set boot PXE first via IPMI interface)

       -  External Network (Optional: Internet access)

5.     16 GB of RAM for a Bare Metal deployment, 64 GB of RAM for a VM deployment.

6.     Minimum 100G storage.

Bare Metal Node Requirements
----------------------------

Bare Metal nodes require:

1.     IPMI enabled on OOB interface for power control.

2.     BIOS boot priority should be PXE first then local hard disk.

3.     Minimum 3 NICs.

       -  PXE installation Network (Broadcasting PXE request)

       -  IPMI Network (Receiving IPMI command from Jumphost)

       -  External Network (OpenStack mgmt/external/storage/tenant network)

Network Requirements
--------------------

Network requirements include:

1.     No DHCP or TFTP server running on networks used by OPNFV.

2.     2-6 separate networks with connectivity between Jumphost and nodes.

       -  PXE installation Network

       -  IPMI Network

       -  Openstack mgmt Network*

       -  Openstack external Network*

       -  Openstack tenant Network*

       -  Openstack storage Network*

3.     Lights out OOB network access from Jumphost with IPMI node enabled (Bare Metal deployment only).

4.     External network has Internet access, meaning a gateway and DNS availability.

**The networks with(*) can be share one NIC(Default configuration) or use an exclusive**
**NIC(Reconfigurated in network.yml).**

Execution Requirements (Bare Metal Only)
----------------------------------------

In order to execute a deployment, one must gather the following information:

1.     IPMI IP addresses for the nodes.

2.     IPMI login information for the nodes (user/pass).

3.     MAC address of Control Plane / Provisioning interfaces of the Bare Metal nodes.

----------------------------------
Installation Guide (BM Deployment)
----------------------------------

Nodes Configuration (BM Deployment)
-----------------------------------

The bellow file is the inventory template of deployment nodes:

"compass4nfv/deploy/conf/hardware_environment/huawei_us_lab/pod1/dha.yml"

You can write your own IPMI IP/User/Password/Mac address/roles reference to it.

        - ipmiVer -- IPMI interface version for deployment node support. IPMI 1.0
          or IPMI 2.0 is available.

        - ipmiIP -- IPMI IP address for deployment node. Make sure it can access
          from Jumphost.

        - ipmiUser -- IPMI Username for deployment node.

        - ipmiPass -- IPMI Password for deployment node.

        - mac -- MAC Address of deployment node PXE NIC .

        - name -- Host name for deployment node after installation.

        - roles -- Components deployed.


**Assignment of different roles to servers**

E.g. Openstack only deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        roles:
          - controller
          - ha

      - name: host2
        roles:
          - compute

NOTE:
IF YOU SELECT MUTIPLE NODES AS CONTROLLER, THE 'ha' role MUST BE SELECT, TOO.

E.g. Openstack and ceph deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        roles:
          - controller
          - ha
          - ceph-admin
          - ceph-mon

      - name: host2
        roles:
          - compute
          - ceph-osd

E.g. Openstack and ODL deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        roles:
          - controller
          - ha
          - odl

      - name: host2
        roles:
          - compute

E.g. Openstack and ONOS deployment roles setting

.. code-block:: yaml

    hosts:
      - name: host1
        roles:
          - controller
          - ha
          - onos

      - name: host2
        roles:
          - compute


Network Configuration (BM Deployment)
-------------------------------------

Before deployment, there are some network configuration to be checked based on your network topology.
Compass4nfv network default configuration file is "compass4nfv/deploy/conf/network_cfg.yaml".
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


Start Deployment (BM Deployment)
--------------------------------

1. Set PXE/Installation NIC for Jumphost. (set eth1 E.g.)

.. code-block:: bash

    export INSTALL_NIC=eth1

2. Set OS version for nodes provisioning. (set Ubuntu14.04 E.g.)

.. code-block:: bash

    export OS_VERSION=trusty

3. Set OpenStack version for deployment nodes. (set liberty E.g.)

.. code-block:: bash

    export OPENSTACK_VERSION=liberty

4. Set ISO image that you want to deploy

.. code-block:: bash

    export ISO_URL=file:///${YOUR_OWN}/compass.iso
    or
    export ISO_URL=http://artifacts.opnfv.org/compass4nfv/brahmaputra/opnfv-release.iso

5. Run ``deploy.sh`` with inventory and network configuration

.. code-block:: bash

    ./deploy.sh --dha ${YOUR_OWN}/dha.yml --network ${YOUR_OWN}/network.yml



