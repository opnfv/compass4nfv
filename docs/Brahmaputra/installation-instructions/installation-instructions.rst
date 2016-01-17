================================================================================================================
OPNFV Installation instructions for the Brahmaputra release of OPNFV when using Compass4nfv as a deployment tool
================================================================================================================


.. contents:: Table of Contents
   :backlinks: none


Abstract
========

This document describes how to install the Brahmaputra release of OPNFV when
using Compass4nfv as a deployment tool covering it's limitations, dependencies
and required system resources.

License
=======

Brahmaputra release of OPNFV when using Compass4nfv as a deployment tool Docs
(c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Brahmaputra release of OPNFV when using Compass4nfv as a deployment tool Docs
are licensed under a Creative Commons Attribution 4.0 International License.
You should have received a copy of the license along with this.
If not, see <http://creativecommons.org/licenses/by/4.0/>.

Version history
===============

+--------------------+--------------------+--------------------+---------------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**               |
|                    |                    |                    |                           |
+--------------------+--------------------+--------------------+---------------------------+
| 2016-01-17         | 1.0.0              | Justin chi         | Rewritten for             |
|                    |                    | (HUAWEI)           | Compass4nfv B release     |
+--------------------+--------------------+--------------------+---------------------------+
| 2015-12-16         | 0.0.2              | Matthew Li         | Minor changes &           |
|                    |                    | (HUAWEI)           | formatting                |
+--------------------+--------------------+--------------------+---------------------------+
| 2015-09-12         | 0.0.1              | Chen Shuai         | First draft               |
|                    |                    | (HUAWEI)           |                           |
+--------------------+--------------------+--------------------+---------------------------+

Introduction
============

This document describes providing guidelines on how to install and
configure the Brahmaputra release of OPNFV when using Compass as a
deployment tool including required software and hardware
configurations.

Installation and configuration of host OS, OpenStack, OpenDaylight,
ONOS, Ceph etc. can be supported by Compass on VMs or Bare Metal
nodes.

The audience of this document is assumed to have good knowledge in
networking and Unix/Linux administration.

Preface
=======

Before starting the installation of the Brahmaputra release of OPNFV
when using Compass4nfv as a deployment tool, some planning must be done.


Retrieving the installation ISO image
-------------------------------------

First of all, The installation ISO is needed for deploying your OPNFV
environment, it included packages of Compass,OpenStack,OpenDaylight,ONOS
and so on. the iso can be retrieved via OPNFV artifacts repository:

http://artifacts.opnfv.org/

NOTE: Search the keyword "Compass4nfv/Brahmaputra" to locate the ISO image.

E.g.
compass4nfv/brahmaputra/opnfv-2016-01-16_15-03-18.iso
compass4nfv/brahmaputra/opnfv-2016-01-16_15-03-18.properties

The name of iso image includes the time of iso building.
The git url and sha1 of Compass4nfv are recorded in properties files,
According these, the corresponding deployment scripts can be retrieved.


Getting the deployment scripts
------------------------------

To retrieve the repository of Compass4nfv on Jumphost use the following command:

- git clone https://<linux foundation uid>@gerrit.opnf.org/gerrit/compass4nfv

NOTE: PLEASE DO NOT GIT CLONE COMPASS4NFV IN root DIRECTORY.

If you don't have a Linux foundation user id, get your own by the url:

https://wiki.opnfv.org/developer/getting_started

Set the branch to the corresponding deployment scripts:

E.g.
Git sha1 in file "opnfv-2016-01-16_15-03-18.properties" is
d5a13ce7cc2ce89946d34b0402ecf33c1d291851

- git checkout d5a13ce7cc2ce89946d34b0402ecf33c1d291851


Preparing the installation environment
--------------------------------------

If you have only 1 Bare Metal server, Virtual deployment is recommended. if more
than 3 servers, the Bare Metal deployment is recommended. The minimum of Bare Metal
deployment server is 3, 1 for JumpServer(Jumphost), 1 for controller, 1 for computer.


Setup Requirements
==================

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

| `*` *These networks can be combined with each other or all combined on the External network(as default).*

Execution Requirements (Bare Metal Only)
----------------------------------------

In order to execute a deployment, one must gather the following information:

1.     IPMI IP addresses for the nodes.

2.     IPMI login information for the nodes (user/pass).

3.     MAC address of Control Plane / Provisioning interfaces of the Bare Metal nodes.


Installation Guide (BM Deployment)
==================================

Nodes Configuration
-------------------

The bellow file is the inventory template of deployment nodes:

"compass4nfv/deploy/conf/hardware_environment/huawei_us_lab/pod1/dha.yml"

You can write your own IPMI IP/User/Password/Mac address/roles reference to it.

NOTE: roles here includes controller compute network storage ha odl and onos.
if you select mutiple nodes as controller, the ha role must be select, too.

Network Configuration
---------------------

Before deployment, there are some network configuration to be checked based on your network topology.
Compass4nfv network default configuration file is "compass4nfv/deploy/conf/network_cfg.yaml".
You can write your own reference to it.

Start Deployment
----------------

1. Set PXE/Installation NIC for Jumphost. (set eth1 E.g.)

export INSTALL_NIC=eth1

2. Set OS version for nodes provisioning. (set Ubuntu14.04 E.g.)

export OS_VERSION=trusty

3. Set OpenStack version for deployment nodes. (set liberty E.g.)

export OPENSTACK_VERSION=liberty

4. Set ISO image that you want to deploy

export ISO_URL=file:///${YOUR_OWN}/compass.iso
or
export ISO_URL=http://artifacts.opnfv.org/compass4nfv/brahmaputra/opnfv-2016-01-16_15-03-18.iso

5. Run ``deploy.sh`` with inventory and network configuration

``./deploy.sh --dha ${YOUR_OWN}/dha.yml --network ${YOUR_OWN}/network.yml``


Installation Guide (VM Deployment)
==================================


References
==========

OPNFV
-----

`OPNFV Home Page <www.opnfv.org>`_

`OPNFV Genesis project page <https://wiki.opnfv.org/get_started>`_

`OPNFV Compass4nfv project page <https://wiki.opnfv.org/compass4nfv>`_

OpenStack
---------

`OpenStack Liberty Release artifacts <http://www.openstack.org/software/liberty>`_

`OpenStack documentation <http://docs.openstack.org>`_

OpenDaylight
------------

`OpenDaylight artifacts <http://www.opendaylight.org/software/downloads>`_

ONOS
----

`ONOS artifacts <http://onosproject.org/software/>`_

Compass
-------

`Compass Home Page <http://www.syscompass.org/>`_

:Authors: Justin Chi (HUAWEI)
:Version: 1.0.0
