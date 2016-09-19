.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

Release Note for the Colorado release of OPNFV when using Compass4nfv as a deployment tool.

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
| **Repo/tag**                         | Compass4nfv/Colorado.1.0             |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Colorado.1.0                         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | September 22 2016                    |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Colorado release               |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Deliverables
------------

Software deliverables
~~~~~~~~~~~~~~~~~~~~~

 - Compass4nfv/Colorado.1.0 ISO, please get it from `OPNFV software download page <https://www.opnfv.org/software/>`_

.. _document-label:

Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~

 - OPNFV(Colorado) Compass4nfv installation instructions

 - OPNFV(Colorado) Compass4nfv Release Notes

Version change
--------------
.. This section describes the changes made since the last version of this document.

Module version change
~~~~~~~~~~~~~~~~~~~~~

This is the Colorado release of compass4nfv as a deployment toolchain in OPNFV, the following
upstream components supported with this release.

 - Ubuntu 14.04.3

 - Openstack (Mitaka release)

 - Opendaylight (Beryllium SR2 release)

 - ONOS (Goldeneye release)

Document version change
~~~~~~~~~~~~~~~~~~~~~~~

Adjusted the document structure, and you can see document at `OPNFV(Colorado) Compass4nfv installation instructions <http://artifacts.opnfv.org/compass4nfv/docs/configguide/index.html>`_.

Reason for new version
----------------------

Feature additions
~~~~~~~~~~~~~~~~~

+--------------------------------------+-----------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                              |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| JIRA: COMPASS-438                    | Add A Task Of ONOS-SFC                  |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| JIRA: COMPASS-443                    | Add MOON in Compass                     |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| JIRA: COMPASS-444                    | Add Xenial-mitaka ODL Support           |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+


Bug corrections
~~~~~~~~~~~~~~~

**JIRA TICKETS:**

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA: COMPASS-459                    | PXE boot may have NO SIGNAL          |
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
| MOON          | First ODL test FAILS because ODL/Openstack   |
|               | federation done in moon is partial. Only     |
|               | MD-SAL is federated (not AD-SAL)             |
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
`See JIRA <https://jira.opnfv.org/issues/?jql=project%20%3D%20COMPASS%20AND%20labels%20%3D%20C-1.0-Workaround>`_

Test Result
===========
The Colorado release with the Compass4nfv deployment toolchain has undergone QA test
runs with the following results:

 - `Functest test result <http://testresults.opnfv.org/reporting/functest/release/colorado/index-status-compass.html>`_
 - `Yardstick test result <http://testresults.opnfv.org/reporting/yardstick/release/colorado/index-status-compass.html>`_
