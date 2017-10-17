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
compass4nfv/deploy/conf/hardware_environment/huawei-pod1/network.yml
OR
compass4nfv_FAQ/deploy/conf/vm_environment/huawei-virtual1/network.yml

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

It uses admin as the default user for OpenStack Dashboard. The password can be achieved as below:

.. code-block:: bash

    sudo docker cp compass-tasks:/opt/openrc ./
    sudo cat openrc | grep OS_PASSWORD

How to visit OpenStack Dashboard
================================

For vm deployment, because NAT bridge is used in virtual deployment, horizon can not be access directly
in external IP address. you need to cofigure the related IPtables rule at first.

.. code-block:: bash

    iptables -t nat -A PREROUTING -d $EX_IP -p tcp --dport  $PORT -j DNAT --to 192.16.1.222:443

The $EX_IP here is the server's ip address that can be access from external.
You can use below command to query your external IP address.

.. code-block:: bash

    external_nic=`ip route |grep '^default'|awk '{print $5F}'
    ip addr show $external_nic
The $PORT here is the one of the port [1- 65535] that does't be used in system.

After that, you can visit OpenStack Dashboard by URL: http://$EX_IP:$PORT

How to access controller nodes after deployment
===============================================

You can login the controller nodes (host1-3) by default user/pass root/root via the install
network IPs which are configured in "compass4nfv/deploy/conf/base.conf", defined as below:

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
    |      Jumphost      |         |          |             |
    |                    |         +----------+    host3    |
    +--------------------+                    |             |
                                              +-------------+


Where is OpenStack RC file
==========================

The RC file named openrc is located in /root in utility container on each controller node as default.
Please source it first if you want to use OpenStack CLI.

.. code-block:: bash

    lxc-attach -n $(lxc-ls | grep utility)
    source /root/openrc

How to recovery network connection after Jumphost reboot
========================================================

.. code-block:: bash

    source deploy/network.sh && save_network_info

How to use Kubernetes CLI
=========================

Login one of the controllers
----------------------------

There are 3 controllers referring to host1 to host3 with IPs from 10.1.0.50 to 10.1.0.52.
The username of the nodes is root, and the password is root.

.. code-block:: bash

    ssh root@10.1.0.50

Run the Kubernetes command
--------------------------

Kubectl controls the Kubernetes cluster manager.

.. code-block:: bash

    kubectl help

Follow the k8s example to create a ngnix service
------------------------------------------------

To create a nginx service, please read Ref[2] at the end of this page.

References
==========

[1]
---

For more information on the Compass4nfv FAQ, please visit

`COMPASS FAQ WIKI Page <https://wiki.opnfv.org/compass4nfv_faq>`_

[2]
---

`K8s Get-Started Page <http://containertutorials.com/get_started_kubernetes/k8s_example.html>`_
