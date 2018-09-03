.. This work is licensed under a Creative Commons Attribution 4.0 International Licence.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Yibo Cai (Arm)

Validated platform
==================

Jump server: Baremetal, Ubuntu 16.04

Node: VM / Baremetal, CentOS 7 / Ubuntu 16.04, K8s 1.9.1

Prepare jump server
===================
A baremetal Arm server is required as Compass4NFV jump server.

#. Install Ubuntu 16.04 aarch64 on jump server.

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

   $ ./build.sh

It downloads and archives Ubuntu/CentOS installation ISO and Compass core docker images for later deployment.


Deploy K8s
==========
This section introduces the steps to deploy K8s cluster in VM and baremetal nodes.

Clear old Compass core
----------------------

Compass core consists of five containers which are responsible for deploying K8s clusters.

- *compass-deck*: provides API service and web UI
- *compass-tasks*: deploy K8s to nodes
- *compass-cobbler*: deploy OS to nodes
- *compass-db*: mysql service
- *compass-mq*: rabbitmq service

Run below command to remove running Compass containers for a clean deployment.

.. code-block:: bash

   $ docker rm -f `docker ps | grep compass | cut -f1 -d' '`

Deploy OS and K8s
-----------------
To deploy CentOS and K8s on two virtual nodes, run:

.. code-block:: bash

   $ ADAPTER_OS_PATTERN='(?i)CentOS-7.*arm.*' \
     OS_VERSION=centos7 \
     KUBERNETES_VERSION=v1.9.1 \
     DHA=deploy/conf/vm_environment/k8-nosdn-nofeature-noha.yml \
     NETWORK=deploy/conf/vm_environment/network.yml \
     VIRT_NUMBER=2 VIRT_CPUS=4 VIRT_MEM=8192 VIRT_DISK=50G \
     ./deploy.sh

To deploy on baremetal nodes, reference below DHA and NETWORK files:

.. code-block:: bash

   DHA="deploy/conf/hardware_environment/huawei-pod8/k8-nosdn-nofeature-noha.yml"
   NETWORK="deploy/conf/hardware_environment/huawei-pod8/network.yml"

To deploy Ubuntu, set:

.. code-block:: bash

   ADAPTER_OS_PATTERN='(?i)ubuntu-16.*arm.*'
   OS_VERSION=xenial
