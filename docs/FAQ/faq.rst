.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)


What is Compass4nfv
===================

Compass4nfv is an installer project based on open source project Compass,
which provides automated deployment and management of OpenStack and other distributed systems.
It can be considered as what the LiveCD to a single box for a pool of servers – bootstrapping
the server pool.

see more information, please visit

`OPNFV Compass4nfv project page <https://wiki.opnfv.org/compass4nfv>`_

`COMPASS Home Page <http://www.syscompass.org/>`_

What's the additional setting in switch if use the default network configuration
================================================================================

Here is the Compass4nfv default network configration file:
compass4nfv/deploy/conf/network_cfg.yaml

It uses a VLAN network for mgmt and storage networks that are share one NIC(eth1) as a
default network configuration. So you need add an additional tagged VLAN (101) and VLAN (102) on
eth1's switch for access.

How to deal with installation failure caused by setting pxe and reset nodes failed
==================================================================================

At first, please make sure that deployed nodes' ipmi network can access from Jumphost and
IPMI user/pass is correct.

Compass4nfv supports IPMI 1.0 or IPMI 2.0 to control your nodes, so you can set it according your IPMI
version in dha.yml.

.. code-block:: yaml

    ipmiVer: '2.0'

How to deal with installation failure caused by "The Server quit without updating PID file"
===========================================================================================

If you see "The Server quit without updating PID file" in installation print log, it is caused by
mgmt network can't access from each deployed nodes, so you need to check your switch setting whether
an additional tagged VLAN is added if uses default network configuration.

How to set OpenStack Dashboard login user and password
======================================================

It uses admin/console as the default user/pass for OpenStack Dashboard, and you can set it in below file:
compass4nfv/deploy/conf/base.conf

How to visit OpenStack Dashboard
================================

You can visit OpenStack Dashboard by URL: http://{puclib_vip}/horizon

The public virtual IP is configured in "compass4nfv/deploy/conf/network_cfg.yaml", defined as below:

.. code-block:: yaml

    public_vip:
      ip: 192.168.50.240

How to access BM nodes after deployment
=======================================

1.     First you should login Compass VM via ssh command on JumpHost by default user/pass root/root.
The default login IP of Compass VM is configured in "compass4nfv/deploy/conf/base.conf", defined as below:

.. code-block:: bash

    export MGMT_IP=${MGMT_IP:-192.168.200.2}

2.     Then you can login the BM nodes (host1-3) by default user/pass root/root via the install network IPs
which are configured in "compass4nfv/deploy/conf/base.conf", defined as below:

.. code-block:: bash

    export MANAGEMENT_IP_START=${MANAGEMENT_IP_START:-'10.1.0.50'}


.. code-block:: console


                                              +-------------+
                                              |             |
                                   +----------+    host1    |
                                   |          |             |
                                   |          +-------------+
                                   |
         +---------+               |          +-------------+
         |         |      install  |          |             |
         | Compass +---------------+----------+    host2    |
         |         |      network  |          |             |
         +---+VM+--+               |          +-------------+
    +--------------------+         |
    |                    |         |          +-------------+
    |      JumpHost      |         |          |             |
    |                    |         +----------+    host3    |
    +--------------------+                    |             |
                                              +-------------+


Where is OpenStack RC file
==========================

It is located /opt/admin-openrc.sh in each BM node as default. Please source it first if you want to use
OpenStack CLI.

References
==========
For more information on the Compass4nfv FAQ, please visit

`COMPASS FAQ WIKI Page <https://wiki.opnfv.org/compass4nfv_faq>`_

