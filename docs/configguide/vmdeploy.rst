.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Installation Guide (Virtual Deployment)
=======================================

Nodes Configuration (Virtual Deployment)
----------------------------------------

The below file is the inventory template of deployment nodes:

"compass4nfv/deploy/conf/vm_environment/huawei-virtual1/network.yml"

You can write your own address/roles reference to it.

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

Before deployment, there are some network configuration to be checked based on your network topology.
Compass4nfv network default configuration file is "compass4nfv/deploy/conf/network_cfg.yaml".
You can write your own reference to it.

**The following figure shows the default network configuration.**

.. code-block:: console


      +--+                          +--+
      |  |                          |  |
      |  |      +------------+      |  |
      |  +------+  Jumphost  +------+  |
      |  |      +------+-----+      |  |
      |  |             |            |  |
      |  |             +------------+  |
      |  |                          |  |
      |  |      +------------+      |  |
      |  +------+    host1   +------+  |
      |  |      +------+-----+      |  |
      |  |             |            |  |
      |  |             +------------+  |
      |  |                          |  |
      |  |      +------------+      |  |
      |  +------+    host2   +------+  |
      |  |      +------+-----+      |  |
      |  |             |            |  |
      |  |             +------------+  |
      |  |                          |  |
      |  |      +------------+      |  |
      |  +------+    host3   +------+  |
      |  |      +------+-----+      |  |
      |  |             |            |  |
      |  |             +------------+  |
      |  |                          |  |
      |  |                          |  |
      +-++                          ++-+
        ^                            ^         
        |                            |         
        |                            |         
      +-+-------------------------+  |         
      |      External Network     |  |         
      +---------------------------+  |         
             +-----------------------+---+     
             | PXE(Installation) Network |     
             +---------------------------+     


Start Deployment (Virtual Deployment)
-------------------------------------

1. Set OS version and OpenStack version for deployment nodes.

    Compass4nfv Colorado supports three OS version based openstack mitaka.

Ubuntu 14.04 mitaka:

.. code-block:: bash

    export OS_VERSION=trusty
    export OPENSTACK_VERSION=mitaka

Ubuntu 16.04 mitaka:

.. code-block:: bash

    export OS_VERSION=xenial
    export OPENSTACK_VERSION=mitaka_xenial

Centos 7 mitaka:

.. code-block:: bash

    export OS_VERSION=centos7
    export OPENSTACK_VERSION=mitaka

2. Set ISO image that you want to deploy

.. code-block:: bash

    export ISO_URL=file:///${YOUR_OWN}/compass.iso
    or
    export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

3. Run ``deploy.sh`` with inventory and network configuration

.. code-block:: bash

    ./deploy.sh --dha ${YOUR_OWN}/dha.yml --network ${YOUR_OWN}/network.yml

E.g.

1. nosdn-nofeature scenario deploy sample

.. code-block:: bash

    ./deploy.sh \
        --dha ./deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml \
        --network ./deploy/conf/vm_environment/huawei-virtual1/network.yml

2. ocl-nofeature scenario deploy sample

.. code-block:: bash

    ./deploy.sh \
        --dha ./deploy/conf/vm_environment/os-ocl-nofeature-ha.yml \
        --network ./deploy/conf/vm_environment/huawei-virtual1/network_ocl.yml

3. odl_l2-moon scenario deploy sample

.. code-block:: bash

    ./deploy.sh \
        --dha ./deploy/conf/vm_environment/os-odl_l2-moon-ha.yml \
        --network ./deploy/conf/vm_environment/huawei-virtual1/network.yml

4. odl_l2-nofeature scenario deploy sample

.. code-block:: bash

    ./deploy.sh \
        --dha ./deploy/conf/vm_environment/os-odl_l2-nofeature-ha.yml \
        --network ./deploy/conf/vm_environment/huawei-virtual1/network.yml

5. odl_l3-nofeature scenario deploy sample

.. code-block:: bash

    ./deploy.sh \
        --dha ./deploy/conf/vm_environment/os-odl_l3-nofeature-ha.yml \
        --network ./deploy/conf/vm_environment/huawei-virtual1/network.yml

6. onos-nofeature scenario deploy sample

.. code-block:: bash

    ./deploy.sh \
        --dha ./deploy/conf/vm_environment/os-onos-nofeature-ha.yml \
        --network ./deploy/conf/vm_environment/huawei-virtual1/network_onos.yml

7. onos-sfc deploy scenario sample

.. code-block:: bash

    ./deploy.sh \
        --dha ./deploy/conf/vm_environment/os-onos-sfc-ha.yml \
        --network ./deploy/conf/vm_environment/huawei-virtual1/network_onos.yml

