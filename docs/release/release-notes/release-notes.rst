.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Release Note for the Fraser release of OPNFV when using Compass4nfv as a deployment tool.

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
| **Repo/tag**                         | Compass4nfv/Fraser.1.0               |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Fraser.1.0                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | March 2018                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Fraser release                 |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Deliverables
------------

Software deliverables
~~~~~~~~~~~~~~~~~~~~~

 - Compass4nfv/Fraser.1.0 tarball, please get it from `OPNFV software download page <https://www.opnfv.org/software/>`_

.. _document-label:

Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~

 - OPNFV(Fraser) Compass4nfv installation instructions

 - OPNFV(Fraser) Compass4nfv Release Notes

Version change
--------------
.. This section describes the changes made since the last version of this document.

Module version change
~~~~~~~~~~~~~~~~~~~~~

This is the Fraser release of compass4nfv as a deployment toolchain in OPNFV, the following
upstream components supported with this release.

 - Ubuntu 16.04.3/Centos 7.4

 - Openstack (Pike release)

 - Kubernates (1.9)

 - Opendaylight (Nitrogen SR1 release)


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


Known issues
------------


Test Result
===========
The Fraser release with the Compass4nfv deployment toolchain has undergone QA test
runs with the following results:

Functest: http://testresults.opnfv.org/reporting/fraser/functest/status-compass.html

