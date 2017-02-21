.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Release Note for the Danube release of OPNFV when using Compass4nfv as a deployment tool.

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
| **Repo/tag**                         | Compass4nfv/Danube.1.0               |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Danube.1.0                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | March 27 2017                        |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Danube release                 |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Deliverables
------------

Software deliverables
~~~~~~~~~~~~~~~~~~~~~

 - Compass4nfv/Danube.1.0 ISO, please get it from `OPNFV software download page <https://www.opnfv.org/software/>`_

.. _document-label:

Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~

 - OPNFV(Danube) Compass4nfv installation instructions

 - OPNFV(Danube) Compass4nfv Release Notes

Version change
--------------
.. This section describes the changes made since the last version of this document.

Module version change
~~~~~~~~~~~~~~~~~~~~~

This is the Danube release of compass4nfv as a deployment toolchain in OPNFV, the following
upstream components supported with this release.

 - Ubuntu 16.04/Centos 7.3

 - Openstack (Newton release)

 - Opendaylight (Boron SR2 release)

 - ONOS (J-bird release/later release)

Document version change
~~~~~~~~~~~~~~~~~~~~~~~

Adjusted the document structure, and you can see document at `OPNFV(Danube) Compass4nfv installation instructions <http://artifacts.opnfv.org/compass4nfv/docs/configguide/index.html>`_.

Reason for new version
----------------------

Feature additions
~~~~~~~~~~~~~~~~~

+--------------------------------------+-----------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                              |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
|                                      |                                         |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+


Bug corrections
~~~~~~~~~~~~~~~

**JIRA TICKETS:**

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
|                                      |                                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+


Known Limitations, Issues and Workarounds
=========================================

System Limitations
------------------

**Max number of blades:** 1 Jumphost, 3 Controllers, 20 Compute blades

**Min number of blades:** 1 Jumphost, 1 Controller, 1 Compute blade

**Storage:** Ceph is the only supported storage configuration

**Min Jumphost requirements:** At least 16GB of RAM, 16 core CPU

Known issues
------------

+---------------+----------------------------------------------+
| **Scenario**  | **Issue**                                    |
+---------------+----------------------------------------------+
|               |                                              |
+---------------+----------------------------------------------+
|               |                                              |
+---------------+----------------------------------------------+

**JIRA TICKETS:**

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                |                                      |
+--------------------------------------+--------------------------------------+

Workarounds
-----------


Test Result
===========
The Danube release with the Compass4nfv deployment toolchain has undergone QA test
runs with the following results:


