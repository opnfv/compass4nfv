.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Expansion Guide
===============

Edit NETWORK File
-----------------

The below file is the inventory template of deployment nodes:

    "./deploy/conf/hardware_environment/huawei-pod1/network.yml"

You can edit the network.yml which you had edited before the first deployment.

NOTE:
External subnet's ip_range should be changed as the first 6 IPs are already taken
by the first deployment.

Edit DHA File
-------------

The below file is the inventory template of deployment nodes:

"./deploy/conf/hardware_environment/expansion-sample/hardware_cluster_expansion.yml"

You can write your own IPMI IP/User/Password/Mac address/roles reference to it.

        - name -- Host name for deployment node after installation.

        - ipmiIP -- IPMI IP address for deployment node. Make sure it can access
          from Jumphost.

        - ipmiUser -- IPMI Username for deployment node.

        - ipmiPass -- IPMI Password for deployment node.

        - mac -- MAC Address of deployment node PXE NIC .

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

**Assignment of roles to servers**

E.g. Only increase one compute node

.. code-block:: yaml

    hosts:
       - name: host6
         mac: 'E8:4D:D0:BA:60:45'
         interfaces:
            - eth1: '08:4D:D0:BA:60:44'
         ipmiIp: 172.16.131.23
         roles:
           - compute


E.g. Increase two compute nodes

.. code-block:: yaml

    hosts:
       - name: host6
         mac: 'E8:4D:D0:BA:60:45'
         interfaces:
            - eth1: '08:4D:D0:BA:60:44'
         ipmiIp: 172.16.131.23
         roles:
           - compute

       - name: host6
         mac: 'E8:4D:D0:BA:60:78'
         interfaces:
            - eth1: '08:4D:56:BA:60:83'
         ipmiIp: 172.16.131.23
         roles:
           - compute

Start Expansion
~~~~~~~~~~~~~~~

1. Edit network.yml and dha.yml file

   You need to Edit network.yml and virtual_cluster_expansion.yml or
   hardware_cluster_expansion.yml. Edit the DHA and NETWORK envionment variables.
   External subnet's ip_range and management ip should be changed as the first 6
   IPs are already taken by the first deployment.

E.g.

.. code-block:: bash

    --- network.yml	2017-02-16 20:07:10.097878150 +0800
    +++ network_expansion.yml	2017-02-17 11:40:08.734480478 +0800
    @@ -56,7 +56,7 @@
       - name: external
         ip_ranges:
    -      - - "192.168.116.201"
    +      - - "192.168.116.206"
             - "192.168.116.221"
         cidr: "192.168.116.0/24"
         gw: "192.168.116.1"

2. Edit deploy.sh

2.1. Set EXPANSION and VIRT_NUMBER.
     VIRT_NUMBER decide how many virtual machines needs to expand when virtual expansion

E.g.

.. code-block:: bash

    export EXPANSION="true"
    export MANAGEMENT_IP_START="10.1.0.55"
    export VIRT_NUMBER=1
    export DEPLOY_FIRST_TIME="false"


2.2. Set scenario that you need to expansion

E.g.

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/expansion-sample/hardware_cluster_expansion.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

Note: Other environment variable shoud be same as your first deployment.
      Please check the environment variable before you run deploy.sh.

2. Run ``deploy.sh``

.. code-block:: bash

    ./deploy.sh
