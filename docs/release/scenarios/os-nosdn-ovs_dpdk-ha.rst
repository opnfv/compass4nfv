.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Justin Chi (HUAWEI) and Yifei Xue (HUAWEI)

This document introduces scenario descriptions for Euphrates 2.0 of
deployment with no SDN controller and no feature enabled.

.. contents::
   :depth: 3
   :local:

=====================
os-nosdn-ovs_dpdk-ha
=====================

This scenario is used to deploy an Ocata OpenStack deployment with
Ceph Jewel, DPDK feature enabled, without SDN controller.

Scenario components and composition
===================================

This scenario includes a set of common OpenStack services which are Nova,
Neutron, Glance, Cinder, Keystone, Heat, Ceilometer, Gnocchi, Aodh,
Horizon. Ceph is used as the backend of Cinder on deployed hosts. HAproxy
is used to balance all the services running on 3 control nodes behind a
VIP (Virtual IP address). Enables high performance data plane acceleration
by utilizing DPDK enabled Open vSwitch (OVS). Changes the dirver of interface
for tenant network to support DPDK.

Scenario usage overview
=======================

To deploy with this scenario, you just need to assign the
os-nosdn-ovs_dpdk-ha.yml to DHA file before deployment.

Limitations, Issues and Workarounds
===================================

References
==========

For more information on the OPNFV Euphrates release, please visit
http://www.opnfv.org/euphrates
