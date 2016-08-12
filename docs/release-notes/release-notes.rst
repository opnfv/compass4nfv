.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Weidong Shao (HUAWEI) and Justin Chi (HUAWEI)

=============================================================================================
Release Note for the Brahmaputra release of OPNFV when using Compass4nfv as a deployment tool
=============================================================================================


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
| **Release date**                     | 2016.2.25                            |
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

This is the first release of compass4nfv as a deployment toolchain in OPNFV, the following
upstream components supported with this release.

 - Ubuntu 14.04.3

 - Openstack (Liberty release)

 - Opendaylight (Beryllium rc1 release)

 - ONOS (Emu release)

Document version change
~~~~~~~~~~~~~~~~~~~~~~~

None due to first release, and you can see document :ref:`document-label`.

Reason for new version
----------------------

Feature additions
~~~~~~~~~~~~~~~~~

+--------------------------------------+-----------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                              |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| JIRA: COMPASS-34                     | Support OpenStack Liberty deployment    |
|                                      |                                         |
+--------------------------------------+-----------------------------------------+
| JIRA: COMPASS-307                    | Integration OpenDaylight Beryllium      |
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
| JIRA:                                |                                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+


Known Limitations, Issues and Workarounds
=========================================

System Limitations
------------------

Known issues
------------

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
See JIRA: <link>

Test Result
===========
The Brahmaputra release with the Compass4nfv deployment toolchain has undergone QA test
runs with the following results:

 - `Functest test result <http://artifacts.opnfv.org/functest/docs/results/overview.html>`_
 - `Yardstick test result <http://testresults.opnfv.org/grafana/>`_

References
==========
For more information on the OPNFV Brahmaputra release, please visit
http://www.opnfv.org/brahmaputra
