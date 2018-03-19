.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Justin Chi (HUAWEI) and Yifei Xue (HUAWEI)

This document introduces scenario descriptions for Fraser 1.0 of
deployment with the OpenDaylight controller and SFC feature enabled.

.. contents::
   :depth: 3
   :local:

=============
os-odl-sfc-ha
=============

This scenario is used to deploy an Pike OpenStack deployment with
OpenDaylight Nitrogen, Ceph Jewel, and SFC feature enabled.

Scenario components and composition
===================================

This scenario includes a set of common OpenStack services which are Nova,
Neutron, Glance, Cinder, Keystone, Heat, Ceilometer, Gnocchi, Aodh,
Horizon. Ceph is used as the backend of Cinder on deployed hosts. HAproxy
is used to balance all the services running on 3 control nodes behind a
VIP (Virtual IP address). OpenDaylight will also be deployed in this
scenario. ODL is also running in HA. Neutron communicates with ODL
through a VIP. Open vSwitch with NSH patched is used instead of native
Open vSwitch to support ODL SFC. Neutron communicates with ODL SFC to
create port pair, classifier, port chain and etc.

Scenario usage overview
=======================

To deploy with this scenario, you just need to assign the
os-odl-nofeature-ha.yaml to DHA file before deployment.

Limitations, Issues and Workarounds
===================================

References
==========

For more information on the OPNFV Fraser release, please visit
http://www.opnfv.org/fraser
