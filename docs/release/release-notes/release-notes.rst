.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Release Note for the Euphrates release of OPNFV when using Compass4nfv as a deployment tool.

Abstract
========

This document describes release notes of OPNFV when using Compass4nfv as a
deployment tool covering it's features, limitations and required system resources.

Introduction
============

Compass4nfv is an OPNFV installer project based on open source project Compass,
which provides automated deployment and management of OpenStack and other distributed systems.
Please carefully follow the Installation Instructions to deploy OPNFV using Compass4nfv
installer.

Release Data
============

+--------------------------------------+--------------------------------------+
| **Project**                          | Compass4nfv                          |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Repo/tag**                         | Compass4nfv/opnfv-5.1.0              |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Euphrates 5.1.0                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | December 2017                        |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Euphrates release              |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Deliverables
------------

Software deliverables
~~~~~~~~~~~~~~~~~~~~~

 - Compass4nfv/opnfv-5.1.0 tarball, please get it from `OPNFV software download page <https://www.opnfv.org/software/>`_

.. _document-label:

Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~

 - OPNFV(Euphrates) Compass4nfv installation instructions

 - OPNFV(Euphrates) Compass4nfv Release Notes

Version change
--------------
.. This section describes the changes made since the last version of this document.

Module version change
~~~~~~~~~~~~~~~~~~~~~

This is the Euphrates release of compass4nfv as a deployment toolchain in OPNFV, the following
upstream components supported with this release.

 - Ubuntu 16.04/Centos 7.3

 - Openstack (Ocata release)

 - Kubernates (1.7.3)

 - Opendaylight (Nitrogen release)


Reason for new version
----------------------

Feature additions
~~~~~~~~~~~~~~~~~

+--------------------------------------+-----------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                              |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| COMPASS-549                          | Real Time KVM                           |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
|                                      | OpenDaylight Nitrogen Support           |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| COMPASS-542                          | Support OpenStack Ocata                 |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
|                                      | Support ODL SFC                         |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| COMPASS-550                          | Support OVS-DPDK                        |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| COMPASS-495                          | Yardstick Integration into Compass4nfv  |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+


Bug corrections
~~~~~~~~~~~~~~~

**JIRA TICKETS:**

+--------------------------------------+----------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                             |
|                                      |                                        |
+--------------------------------------+----------------------------------------+
|                                      | With no ceph, the cluster will heal    |
|                                      | itself after a power failure or reboot |
+--------------------------------------+----------------------------------------+


Known Limitations, Issues and Workarounds
=========================================

System Limitations
------------------

**Max number of blades:** 1 Jumphost, 3 Controllers, 20 Compute blades

**Min number of blades:** 1 Jumphost, 1 Controller, 1 Compute blade

**Storage:** Ceph is the only supported storage configuration

**Min Jumphost requirements:** At least 16GB of RAM, 16 core CPU

Scenario Limitations
--------------------

**ODL SFC:** In the Euphrates 1.0, Compass doesn't integrate OpenStack Tacker
Project yet. However, the SFC related test cases in Functest always use Tacker
as NFVO to delivery VNFFG or SFC related requests to ODL via networking-sfc.
So the odl-sfc scenario of Compass cannot pass the SFC testcases in Functest.
But if you want to use verify SFC in the cluster deployed by Compass, you can
use neutron CLI to achieve the same effect.

Known issues
------------

+-----------------------+---------------------------------+-----------------------+
|   **Scenario**        | **Issue**                       |  **Workarounds**      |
+-----------------------+---------------------------------+-----------------------+
| Ceph Related Scenario | After a power failure or reboot,| Deploy without Ceph   |
|                       | the cluster cannot heal itself  |                       |
+-----------------------+---------------------------------+-----------------------+

Test Result
===========
The Euphrates release with the Compass4nfv deployment toolchain has undergone QA test
runs with the following results:

Functest: http://testresults.opnfv.org/reporting/euphrates/functest/status-compass.html

