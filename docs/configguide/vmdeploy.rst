.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Installation Guide (VM Deployment)
==================================

Nodes Configuration (VM Deployment)
-----------------------------------

Please follow the instructions in section `Installation Guide (BM Deployment)`,
and no need to set IPMI/PXE/MAC parameters.

Network Configuration (VM Deployment)
-------------------------------------

Please follow the instructions in section `Installation Guide (BM Deployment)`.

Start Deployment (VM Deployment)
--------------------------------

1. Set OS version for nodes provisioning. (set Ubuntu14.04 E.g.)

.. code-block:: bash

    export OS_VERSION=trusty

3. Set OpenStack version for deployment nodes. (set liberty E.g.)

.. code-block:: bash

    export OPENSTACK_VERSION=liberty

4. Set ISO image that you want to deploy

.. code-block:: bash

    export ISO_URL=file:///${YOUR_OWN}/compass.iso
    or
    export ISO_URL=http://artifacts.opnfv.org/compass4nfv/brahmaputra/opnfv-release.iso

5. Run ``deploy.sh`` with inventory and network configuration

.. code-block:: bash

    ./deploy.sh --dha ${YOUR_OWN}/dha.yml --network ${YOUR_OWN}/network.yml
