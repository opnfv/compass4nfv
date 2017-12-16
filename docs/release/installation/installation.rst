.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Compass4nfv configuration
=========================

This document describes providing guidelines on how to install and
configure the Euphrates release of OPNFV when using Compass4nfv as a
deployment tool including required software and hardware
configurations.

Installation and configuration of host OS, OpenStack, OpenDaylight,
ONOS, Ceph etc. can be supported by Compass on Virtual nodes or Bare Metal
nodes.

The audience of this document is assumed to have good knowledge in
networking and Unix/Linux administration.


Preconditions
-------------

Before starting the installation of the Euphrates release of OPNFV,
some planning must be done.


Retrieving the installation Tarball
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First of all, The installation tarball is needed for deploying your OPNFV
environment, it included packages of compass docker images and OSA repo.

The stable tarball can be retrieved via `OPNFV software download page <https://www.opnfv.org/software>`_

The daily build tarball can be retrieved via OPNFV artifacts repository:

http://artifacts.opnfv.org/compass4nfv.html

NOTE: Search the keyword "compass4nfv/Euphrates" to locate the ISO image.

E.g.
compass4nfv/Euphrates/opnfv-2017-09-18_08-15-13.tar.gz

The name of tarball includes the time of iso building, you can get the daily
ISO according the building time.
The git url and sha1 of Compass4nfv are recorded in properties files,
According these, the corresponding deployment scripts can be retrieved.


Getting the deployment scripts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To retrieve the repository of Compass4nfv on Jumphost use the following command:

- git clone https://gerrit.opnfv.org/gerrit/compass4nfv

NOTE: PLEASE DO NOT GIT CLONE COMPASS4NFV IN ROOT DIRECTORY(INCLUDE SUBFOLDERS).

To get stable /Euphrates release, you can use the following command:

- git checkout opnfv-5.1.0

Setup Requirements
------------------

If you have only 1 Bare Metal server, Virtual deployment is recommended. if more
than or equal 3 servers, the Bare Metal deployment is recommended. The minimum number of
servers for Bare metal deployment is 3, 1 for JumpServer(Jumphost), 1 for controller,
1 for compute.


Jumphost Requirements
~~~~~~~~~~~~~~~~~~~~~

The Jumphost requirements are outlined below:

1.     Ubuntu 14.04 (Pre-installed).

2.     Root access.

3.     libvirt virtualization support.

4.     Minimum 2 NICs.

       -  PXE installation Network (Receiving PXE request from nodes and providing OS provisioning)

       -  IPMI Network (Nodes power control and set boot PXE first via IPMI interface)

       -  External Network (Optional: Internet access)

5.     16 GB of RAM for a Bare Metal deployment, 64 GB of RAM for a Virtual deployment.

6.     CPU cores: 32, Memory: 64 GB, Hard Disk: 500 GB, (Virtual Deployment needs 1 TB Hard Disk)


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

       -  br-mgmt Network*

       -  br-vlan Network*

       -  br-tenant Network*

       -  br-storage Network*

3.     Lights out OOB network access from Jumphost with IPMI node enabled (Bare Metal deployment only).

4.     br-vlan network has Internet access, meaning a gateway and DNS availability.

**The networks with(*) can be share one NIC(Default configuration) or use an exclusive**
**NIC(Reconfigurated in network.yml).**


Execution Requirements (Bare Metal Only)
----------------------------------------

In order to execute a deployment, one must gather the following information:

1.     IPMI IP addresses of the nodes.

2.     IPMI login information for the nodes (user/pass).

3.     MAC address of Control Plane / Provisioning interfaces of the Bare Metal nodes.


Configurations
---------------

There are three configuration files a user needs to modify for a cluster deployment.
``network_cfg.yaml`` for openstack networks on hosts.
``dha file`` for host role, IPMI credential and host nic idenfitication (MAC address).
``deploy.sh`` for os and openstack version.
