.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Expansion Guide
===============

Bare Metal Expansion
--------------------

Edit NETWORK File
~~~~~~~~~~~~~~~~~

The below file is the inventory template of deployment nodes:

    "./deploy/conf/hardware_environment/huawei-pod1/network.yml"

You can edit the network.yml which you had edited before the first deployment.

NOTE:
External subnet's ip_range should be changed as the first 6 IPs are already taken
by the first deployment.

Edit DHA File
~~~~~~~~~~~~~

The below file is the inventory template of deployment nodes:

"./deploy/conf/hardware_environment/expansion-sample/hardware_cluster_expansion.yml"

You can write your own IPMI IP/User/Password/Mac address/roles reference to it.

        - name -- Host name for deployment node after installation.

        - ipmiIP -- IPMI IP address for deployment node. Make sure it can access
          from Jumphost.

        - ipmiUser -- IPMI Username for deployment node.

        - ipmiPass -- IPMI Password for deployment node.

        - mac -- MAC Address of deployment node PXE NIC .

E.g. Only increase one compute node

.. code-block:: yaml

    TYPE: baremetal
    FLAVOR: cluster
    POWER_TOOL: ipmitool

    ipmiUser: root
    ipmiPass: Huawei@123

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

    TYPE: baremetal
    FLAVOR: cluster
    POWER_TOOL: ipmitool

    ipmiUser: root
    ipmiPass: Huawei@123

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

1. Edit add.sh

YOUR_ISO is your iso's absolute path.

E.g.

.. code-block:: bash

    export ISO_URL=file:///home/compass/compass4nfv/work/build/compass.iso

YOUR_DHA is your dha.yml's path
YOUR_NETWORK is your network.yml's path

E.g.

.. code-block:: bash

    export DHA=/home/compass/compass4nfv/deploy/conf/hardware_environment/
            expansion-sample/hardware_cluster_expansion.yml
    export NETWORK=/home/compass/compass4nfv/deploy/conf/hardware_environment/
            huawei-pod1/network.yml

Comment out VIRT_NUMBER

E.g.

.. code-block:: bash

    #export VIRT_NUMBER=1

Modify the install NIC

E.g.

.. code-block:: bash

    INSTALL_NIC=${INSTALL_NIC:-eth1}

Check the environment variable. 

NOTE:
The OS version and OpenStack version should be same as the first deployment.

2. Run ``add.sh``

.. code-block:: bash

    ./add.sh

Virtual Expansion
-----------------

Edit network.yml
~~~~~~~~~~~~~~~~

The below file is the inventory template of deployment nodes:

    "./deploy/conf/vm_environment/huawei-virtual1/network.yml"

You can edit the network.yml which you had edited before the first deployment.

NOTE:
External subnet's ip_range should be changed as the first 6 IPs are already taken
by the first deployment.

Edit dha.yml
~~~~~~~~~~~~

The below file is the inventory template of deployment nodes:

"./deploy/conf/vm_environment/virtual_cluster_expansion.yml"

You can edit host names and roles.

E.g. Only increase one compute node

.. code-block:: yaml

    TYPE: virtual
    FLAVOR: cluster

    hosts:
      - name: host6
        roles:
          - compute

E.g. Increase two compute nodes

.. code-block:: yaml

    TYPE: virtual
    FLAVOR: cluster

    hosts:
      - name: host6
        roles:
          - compute

      - name: host7
        roles:
          - compute

Start Expansion
~~~~~~~~~~~~~~~

1. Edit add.sh

YOUR_ISO is your iso's absolute path.

E.g.

.. code-block:: bash

    export ISO_URL=file:///home/compass/compass4nfv/work/build/compass.iso

YOUR_DHA is your dha.yml's path
YOUR_NETWORK is your network.yml's path

E.g.

.. code-block:: bash

    export DHA=/home/liyuenan/compass4nfv_add/deploy/conf/vm_environment/
            virtual_cluster_expansion.yml
    export NETWORK=/home/liyuenan/compass4nfv_add/deploy/conf/vm_environment/
            huawei-virtual1/network.yml

You can decide hou many nodes you need expansion by modify the VIRT_NUMBER

E.g.

.. code-block:: bash

    export VIRT_NUMBER=2

Comment out NIC

E.g.

.. code-block:: bash

    #INSTALL_NIC=${INSTALL_NIC:-eth1}

Check the environment variable. 

NOTE:
The OS version and OpenStack version should be same as the first deployment.

2. Run ``add.sh``

.. code-block:: bash

    ./add.sh
