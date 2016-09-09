.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Compass4nfv configuration
=========================

This document describes providing guidelines on how to install and
configure the Colorado release of OPNFV when using Compass as a
deployment tool including required software and hardware
configurations.

Installation and configuration of host OS, OpenStack, OpenDaylight,
ONOS, Ceph etc. can be supported by Compass on Virtual nodes or Bare Metal
nodes.

The audience of this document is assumed to have good knowledge in
networking and Unix/Linux administration.


Preconditions
-------------

Before starting the installation of the Colorado release of OPNFV,
some planning must be done.


Retrieving the installation ISO image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First of all, The installation ISO is needed for deploying your OPNFV
environment, it included packages of Compass, OpenStack, OpenDaylight, ONOS
and so on.

The stable release ISO can be retrieved via `OPNFV software download page <https://www.opnfv.org/software>`_

The daily build ISO can be retrieved via OPNFV artifacts repository:

http://artifacts.opnfv.org/

NOTE: Search the keyword "compass4nfv/Colorado" to locate the ISO image.

E.g.
compass4nfv/colorado/opnfv-2016-01-16_15-03-18.iso
compass4nfv/colorado/opnfv-2016-01-16_15-03-18.properties

The name of iso image includes the time of iso building, you can get the daily
ISO according the building time.
The git url and sha1 of Compass4nfv are recorded in properties files,
According these, the corresponding deployment scripts can be retrieved.


Getting the deployment scripts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To retrieve the repository of Compass4nfv on Jumphost use the following command:

- git clone https://gerrit.opnfv.org/gerrit/compass4nfv

NOTE: PLEASE DO NOT GIT CLONE COMPASS4NFV IN root DIRECTORY(Include subfolders).

To get stable /colorado release, you can use the following command:

- git checkout colorado.1.0

If you want to use a daily release ISO, please checkout the corresponding sha1 to
get the deployment scripts:

E.g.
Git sha1 in file "opnfv-2016-01-16_15-03-18.properties" is
d5a13ce7cc2ce89946d34b0402ecf33c1d291851

- git checkout d5a13ce7cc2ce89946d34b0402ecf33c1d291851


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

6.     CPU cores: 32, Memory: 64 GB, Hard Disk: 500 GB, (Virtual Deloment needs 1 TB Hard Disk)


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

1.     IPMI IP addresses of the nodes.

2.     IPMI login information for the nodes (user/pass).

3.     MAC address of Control Plane / Provisioning interfaces of the Bare Metal nodes.
