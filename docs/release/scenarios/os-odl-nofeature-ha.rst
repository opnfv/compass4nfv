.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Justin Chi (HUAWEI) and Yifei Xue (HUAWEI)

This document introduces scenario descriptions for Gambia 1.0 of
deployment with the OpenDaylight controller and no feature enabled.

.. contents::
   :depth: 3
   :local:

===================
os-odl-nofeature-ha
===================

This scenario is used to deploy a Pike OpenStack deployment with
OpenDaylight Nitrogen SR1, Ceph Luminous, and without any NFV feature enabled.

Scenario components and composition
===================================

This scenario includes a set of common OpenStack services which are Nova,
Neutron, Glance, Cinder, Keystone, Heat, Ceilometer, Gnocchi, Aodh,
Horizon. Ceph is used as the backend of Cinder on deployed hosts. HAproxy
is used to balance all the services running on 3 control nodes behind a
VIP (Virtual IP address). OpenDaylight will also be deployed in this
scenario. ODL is also running in HA. Neutron communicates with ODL
through a VIP.

Scenario usage overview
=======================

To deploy with this scenario, you just need to assign the
os-odl-nofeature-ha.yaml to DHA file before deployment.

Limitations, Issues and Workarounds
===================================

References
==========

For more information on the OPNFV Gambia release, please visit
http://www.opnfv.org/gambia
