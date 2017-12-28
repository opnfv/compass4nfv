.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Yibo Cai (Arm)

Validated platform
==================

================  =========  ================  ========
        Jump server                     Node
---------------------------  --------------------------
distro            libvirt    distro            k8s
================  =========  ================  ========
ubuntu 16.04.3    1.3.1      centos7 1708      1.7.3
================  =========  ================  ========

Prepare jump server
===================
This document assumes you are using a baremetal Arm server as Compass4NFV jump server. It's possible to deploy jump server inside a virtual machine, this case is not covered here.

#. Install Ubuntu 16.04.3 aarch6 on jump server.

#. Install required packages.

   .. code-block:: bash

      $ sudo apt install docker.io libvirt-bin virt-manager qemu qemu-efi

#. Disable DHCP of default libvirt network.

   Libvirt creates a default network at intallation, which enables DHCP and occupies port 67. It conflicts with compass-cobbler container.

   .. code-block:: bash

      $ sudo virsh net-edit default

   .. code-block:: xml

      <!-- remove below lines and save/quit ->
      <dhcp>
        <range start='192.168.122.2' end='192.168.122.254'/>
      </dhcp>

   .. code-block:: bash

      $ sudo virsh net-destroy default
      $ sudo virsh net-start default

#. Make sure ports 67, 69, 80, 443 are free.

   Compass-cobber requires ports 67, 69 to provide DHCP and TFTP services. Compass-deck provides HTTP and HTTPS through ports 80, 443. All these ports should be free before deployment.

#. Tear down apparmor service.

   .. code-block:: bash

      $ sudo service apparmor teardown

#. Enable password-less sudo for current user (optional).


Build Arm tarball
=================

Clone Compass4NFV code. Run below command to build deployment tarball for Arm.

.. code-block:: bash

   $ COMPASS_ISO_REPO='http://people.linaro.org/~yibo.cai/compass' ./build.sh

It downloads and archives Ubuntu/CentOS installation ISO and Compass core docker images for later deployment.


Deploy K8s in VM
================
This section introduces the steps to deploy K8s cluster in virtual machines running on jump server. Two VM nodes will be created, one master and one minion, with flannel networking.

Deploy Compass core
-------------------

Compass core consists of five containers which are responsible for deploying K8s clusters.

- *compass-deck*: provides API service and web UI
- *compass-tasks*: deploy K8s to nodes
- *compass-cobbler*: deploy OS to nodes
- *compass-db*: mysql service
- *compass-mq*: rabbitmq service

Run below command to deploy Compass core on jump server.

.. code-block:: bash

   $ DEPLOY_COMPASS='true' \
     DHA=${PWD}/deploy/conf/vm_environment/k8-nosdn-nofeature-noha.yml \
     NETWORK=${PWD}/deploy/conf/vm_environment/network.yml \
     ./deploy.sh


Deploy OS and K8s
-----------------
To deploy OS and K8s on two virtual nodes, run:

.. code-block:: bash

   $ DEPLOY_HOST='true' \
     ADAPTER_OS_PATTERN='(?i)CentOS-7.*arm.*' \
     OS_VERSION=centos7 \
     KUBERNETES_VERSION=v1.7.3 \
     DHA=${PWD}/deploy/conf/vm_environment/k8-nosdn-nofeature-noha.yml \
     NETWORK=${PWD}/deploy/conf/vm_environment/network.yml \
     VIRT_NUMBER=2 VIRT_CPUS=2 VIRT_MEM=4096 VIRT_DISK=50G \
     ./deploy.sh
