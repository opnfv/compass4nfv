.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

==========================================================================================================
Installation instructions for the Brahmaputra release of OPNFV when using Compass4nfv as a deployment tool
==========================================================================================================


Abstract
========

This document describes how to install the Brahmaputra release of OPNFV when
using Compass4nfv as a deployment tool covering it's limitations, dependencies
and required system resources.

Version history
===============

+--------------------+--------------------+--------------------+---------------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**               |
|                    |                    |                    |                           |
+--------------------+--------------------+--------------------+---------------------------+
| 2016-01-17         | 1.0.0              | Justin chi         | Rewritten for             |
|                    |                    | (HUAWEI)           | Compass4nfv B release     |
+--------------------+--------------------+--------------------+---------------------------+
| 2015-12-16         | 0.0.2              | Matthew Li         | Minor changes &           |
|                    |                    | (HUAWEI)           | formatting                |
+--------------------+--------------------+--------------------+---------------------------+
| 2015-09-12         | 0.0.1              | Chen Shuai         | First draft               |
|                    |                    | (HUAWEI)           |                           |
+--------------------+--------------------+--------------------+---------------------------+

.. include:: ./installerconfig.rst

----------------------------------
Installation Guide (VM Deployment)
----------------------------------

Nodes Configuration
-------------------

Please follow the instructions in section `Installation Guide (BM Deployment)`,
and no need to set IPMI/PXE/MAC parameters.

Network Configuration
---------------------

Please follow the instructions in section `Installation Guide (BM Deployment)`.

Start Deployment
----------------

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

References
==========

OPNFV
-----

`OPNFV Home Page <www.opnfv.org>`_

`OPNFV Genesis project page <https://wiki.opnfv.org/get_started>`_

`OPNFV Compass4nfv project page <https://wiki.opnfv.org/compass4nfv>`_

OpenStack
---------

`OpenStack Liberty Release artifacts <http://www.openstack.org/software/liberty>`_

`OpenStack documentation <http://docs.openstack.org>`_

OpenDaylight
------------

`OpenDaylight artifacts <http://www.opendaylight.org/software/downloads>`_

ONOS
----

`ONOS artifacts <http://onosproject.org/software/>`_

Compass
-------

`Compass Home Page <http://www.syscompass.org/>`_

:Authors: Justin Chi (HUAWEI)

