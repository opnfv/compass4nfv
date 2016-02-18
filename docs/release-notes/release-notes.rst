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
Provide a brief introduction of how this release is used in OPNFV release using <XYZ> as a deployment tool

Be sure to reference your installation-instructions.

Release Data
============

+--------------------------------------+--------------------------------------+
| **Project**                          | Compass4nfv                          |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Repo/tag**                         | Compass4nfv/Brahmaputra.1.0          |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Brahmaputra.1.0                      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | 2016.2.25                            |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Brahmaputra release            |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Deliverables
------------

Software deliverables
~~~~~~~~~~~~~~~~~~~~~

 - Deployment Script

   It is a part of Compass4nfv repository, the entry of deployment sctripts is "compass4nfv/deploy.sh",
   to retrieve the repository of Compass4nfv by following command:

        git clone https://gerrit.opnfv.org/gerrit/compass4nfv

 - `Compass4nfv ISO link <http://artifacts.opnfv.org/compass4nfv/brahmaputra/opnfv-2016-02-17_14-01-01.iso>`_

.. This link will be updated at final release.

.. _document-label:

Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~

 - `Installation Instructions <http://artifacts.opnfv.org/compass4nfv/brahmaputra/docs/Brahmaputra_installation-instructions/index.html>`_

 - `Release Notes <http://artifacts.opnfv.org/compass4nfv/brahmaputra/docs/Brahmaputra_release-notes/index.html>`_

 - `FAQ <http://artifacts.opnfv.org/compass4nfv/brahmaputra/docs/Brahmaputra_FAQ/index.html>`_

Version change
--------------
.. This section describes the changes made since the last version of this document.

Module version change
~~~~~~~~~~~~~~~~~~~~~

This is the first release of compass4nfv as a deployment toolchain in OPNFV, the following
upstream components supported with this release.

 - Ubuntu 14.04.3

 - Openstack Liberty

 - Opendaylight

 - ONOS Emu

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
| JIRA:                                |                                         |
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
Brahmaputra test result using <Compass4nfv> as deployment tool.

 - `Functest test result <http://artifacts.opnfv.org/functest/docs/results/overview.html>`_

References
==========
For more information on the OPNFV Brahmaputra release, please visit
http://www.opnfv.org/brahmaputra

:Authors: Justin Chi (HUAWEI)
:Version: 0.0.1
