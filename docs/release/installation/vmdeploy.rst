.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Installation on virtual machines
================================

Quick Start
-----------

Only 1 command to try virtual deployment, if you have Internet access. Just Paste it and Run.

.. code-block:: bash

    curl https://raw.githubusercontent.com/opnfv/compass4nfv/stable/gambia/quickstart.sh | bash

If you want to deploy noha with1 controller and 1 compute, run the following command

.. code-block:: bash

    export SCENARIO=os-nosdn-nofeature-noha.yml
    curl https://raw.githubusercontent.com/opnfv/compass4nfv/stable/gambia/quickstart.sh | bash

Nodes Configuration (Virtual Deployment)
----------------------------------------

virtual machine setting
~~~~~~~~~~~~~~~~~~~~~~~

        - VIRT_CPUS -- the number of CPUs allocated per virtual machine.

        - VIRT_MEM -- the memory size(MB) allocated per virtual machine.

        - VIRT_DISK -- the disk size allocated per virtual machine.

.. code-block:: bash

    export VIRT_CPUS=${VIRT_CPU:-4}
    export VIRT_MEM=${VIRT_MEM:-16384}
    export VIRT_DISK=${VIRT_DISK:-200G}


roles setting
~~~~~~~~~~~~~

The below file is the inventory template of deployment nodes:

"./deploy/conf/vm_environment/huawei-virtual1/dha.yml"

The "dha.yml" is a collectively name for "os-nosdn-nofeature-ha.yml
os-ocl-nofeature-ha.yml os-odl_l2-moon-ha.yml etc".

You can write your own address/roles reference to it.

        - name -- Host name for deployment node after installation.

        - roles -- Components deployed.

**Set TYPE and FLAVOR**

E.g.

.. code-block:: yaml

    TYPE: virtual
    FLAVOR: cluster

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
          - ceph-adm
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

Network Configuration (Virtual Deployment)
------------------------------------------

The same with Baremetal Deployment.

Start Deployment (Virtual Deployment)
-------------------------------------

1. Edit deploy.sh

1.1. Set OS version for deployment nodes.
     Compass4nfv supports ubuntu and centos based openstack pike.

E.g.

.. code-block:: bash

    # Set OS version for target hosts
    # Ubuntu16.04 or CentOS7
    export OS_VERSION=xenial
    or
    export OS_VERSION=centos7

1.2. Set ISO image corresponding to your code

E.g.

.. code-block:: bash

    # Set ISO image corresponding to your code
    export ISO_URL=file:///home/compass/compass4nfv.tar.gz

1.3. Set scenario that you want to deploy

E.g.

nosdn-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/vm_environment/huawei-virtual1/network.yml

odl_l2-moon scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/vm_environment/os-odl_l2-moon-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/vm_environment/huawei-virtual1/network.yml

odl_l2-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/vm_environment/os-odl_l2-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/vm_environment/huawei-virtual1/network.yml

odl_l3-nofeature scenario deploy sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/vm_environment/os-odl_l3-nofeature-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/vm_environment/huawei-virtual1/network.yml

odl-sfc deploy scenario sample

.. code-block:: bash

    # DHA is your dha.yml's path
    export DHA=./deploy/conf/vm_environment/os-odl-sfc-ha.yml

    # NETWORK is your network.yml's path
    export NETWORK=./deploy/conf/vm_environment/huawei-virtual1/network.yml

2. Run ``deploy.sh``

.. code-block:: bash

    ./deploy.sh
