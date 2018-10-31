.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) Justin Chi (HUAWEI),Yifei Xue (HUAWEI)and Xinhui Hu (FIBERHOME)

This document introduces scenario descriptions for Gambia 1.0 of
deployment with no SDN controller and no feature enabled.

.. contents::
   :depth: 3
   :local:

======================
k8s-nosdn-nofeature-ha
======================

This scenario is used to deploy an kubernets cluster.

Scenario components and composition
===================================

This scenario includes a set of kubernets services which are kubernets API Server,
Controller Manager, kube-proxy, kubelet,kube-dns,nginx-proxy,kubernetes-dashboard.
Nginx-proxy is used to balance all the services running on 3 control nodes behind
a VIP (Virtual IP address).

Scenario usage overview
=======================

To deploy with this scenario, you just need to assign the
k8s-nosdn-nofeature-ha.yaml to DHA file before deployment.

Limitations, Issues and Workarounds
===================================

References
==========

For more information on the OPNFV Gambia release, please visit
http://www.opnfv.org/gambia
