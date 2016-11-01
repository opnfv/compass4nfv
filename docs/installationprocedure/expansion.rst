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

1. Edit deploy.sh

Set the EXPANSION to true.

E.g.

.. code-block:: bash

    ######################### Deploy or Expansion ###############################
    # Modify network.yml and virtual_cluster_expansion.yml or
    # hardware_cluster_expansion.yml.
    # Edit the DHA and NETWORK envionment variables.
    # External subnet's ip_range and management ip should be changed as the
    # first 6 IPs are already taken by the first deployment.
    # VIRT_NUMBER decide how many virtual machines needs to expand when virtual expansion

    export EXPANSION="true"
    export MANAGEMENT_IP_START="10.1.0.55"
    #export VIRT_NUMBER=1
    export DEPLOY_FIRST_TIME="false"


Set OS version and OpenStack version for deployment nodes.

E.g.

.. code-block:: bash

    ######################### The environment for Openstack ######################
    # Ubuntu16.04 Newton
    #export OS_VERSION=xenial
    #export OPENSTACK_VERSION=newton_xenial

    # Ubuntu14.04 Mitaka
    #export OS_VERSION=trusty
    #export OPENSTACK_VERSION=mitaka

    # Ubuntu16.04 Mitaka
    #export OS_VERSION=xenial
    #export OPENSTACK_VERSION=mitaka_xenial

    # Centos7 Mitaka
    #export OS_VERSION=centos7
    #export OPENSTACK_VERSION=mitaka

    # Redhat7 OSP9
    #export OS_VERSION=redhat7
    #export OPENSTACK_VERSION=osp9

NOTE:
The OS version and OpenStack version should be same as the first deployment.

Set ISO image that you want to deploy

E.g.

.. code-block:: bash

    # ISO_URL is your iso's absolute path
    export ISO_URL=file:///home/compass/compass4nfv.iso
    # or
    # export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

NOTE:
The ISO should be same as the first deployment.

Set scenario that you want to expansion

E.g.

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/hardware_environment/expansion-sample/hardware_cluster_expansion.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/hardware_environment/huawei-pod1/network.yml

Set jumpserver PXE NIC

E.g.

.. code-block:: bash

    INSTALL_NIC=${INSTALL_NIC:-eth1}

Check the environment variable.

2. Run ``deploy.sh``

.. code-block:: bash

    ./deploy.sh

Virtual Expansion
-----------------

Edit NETWORK File
~~~~~~~~~~~~~~~~~

The below file is the inventory template of deployment nodes:

    "./deploy/conf/vm_environment/huawei-virtual1/network.yml"

You can edit the network.yml which you had edited before the first deployment.

NOTE:
External subnet's ip_range should be changed as the first 6 IPs are already taken
by the first deployment.

Edit DHA File
~~~~~~~~~~~~~

The below file is the inventory template of deployment nodes:

"./deploy/conf/vm_environment/virtual_cluster_expansion.yml"

**Set TYPE and FLAVOR**

E.g.

.. code-block:: yaml

    TYPE: virtual
    FLAVOR: cluster

**Assignment of roles to servers**

E.g. Only increase one compute node

.. code-block:: yaml

    hosts:
      - name: host6
        roles:
          - compute

E.g. Increase two compute nodes

.. code-block:: yaml

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

Set the EXPANSION to true.

E.g.

.. code-block:: bash

    ######################### Deploy or Expansion ###############################
    # Modify network.yml and virtual_cluster_expansion.yml or
    # hardware_cluster_expansion.yml.
    # Edit the DHA and NETWORK envionment variables.
    # External subnet's ip_range and management ip should be changed as the
    # first 6 IPs are already taken by the first deployment.
    # VIRT_NUMBER decide how many virtual machines needs to expand when virtual expansion

    export EXPANSION="true"
    export MANAGEMENT_IP_START="10.1.0.55"
    export VIRT_NUMBER=1
    export DEPLOY_FIRST_TIME="false"

Set OS version and OpenStack version for deployment nodes.

E.g.

.. code-block:: bash

    ######################### The environment for Openstack ######################
    # Ubuntu16.04 Newton
    #export OS_VERSION=xenial
    #export OPENSTACK_VERSION=newton_xenial

    # Ubuntu14.04 Mitaka
    #export OS_VERSION=trusty
    #export OPENSTACK_VERSION=mitaka

    # Ubuntu16.04 Mitaka
    #export OS_VERSION=xenial
    #export OPENSTACK_VERSION=mitaka_xenial

    # Centos7 Mitaka
    #export OS_VERSION=centos7
    #export OPENSTACK_VERSION=mitaka

    # Redhat7 OSP9
    #export OS_VERSION=redhat7
    #export OPENSTACK_VERSION=osp9

NOTE:
The OS version and OpenStack version should be same as the first deployment.

Set ISO image that you want to deploy

E.g.

.. code-block:: bash

    # ISO_URL is your iso's absolute path
    export ISO_URL=file:///home/compass/compass4nfv.iso
    # or
    # export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

NOTE:
The OS version and OpenStack version should be same as the first deployment.

Set scenario that you want to expansion

E.g.

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/vm_environment/virtual_cluster_expansion.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/vm_environment/huawei-virtual1/network.yml

Check the environment variable.

2. Run ``deploy.sh``

.. code-block:: bash

    ./deploy.sh
