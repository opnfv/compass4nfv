.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) by Justin Chi (HUAWEI) and Yifei Xue (HUAWEI)

How to integrate a feature into compass4nfv
===========================================

This document describes how to integrate a feature (e.g. sdn, moon, kvm, sfc)
into compass installer. Follow the steps below, you can achieve the goal.

Basic role for the feature
-----------------------------

Currently Ansible is the main packages installation plugin in the adapters of
Compass4nfv, which is used to deploy all the roles listed in the playbooks.
(More details about ansible and playbook can be achieved according to the
Reference[1].) The mostly used playbook in compass4nfv is named
"HA-ansible-multinodes.yml" located in "*your_path_to_compass4nfv*/compass4nfv/deploy/
adapters/ansible/openstack/".

Before you add your role into the playbook, create your role under the directory of
"*your_path_to_compass4nfv*/compass4nfv/deploy/adapters/ansible/roles/". For example
Fig 1 shows some roles currently existed in compass4nfv.


.. figure:: images/Existed_roles.png
    :alt: Existed roles in compass4nfv
    :figclass: align-center

    Fig 1. Existed roles in compass4nfv


Let's take a look at "moon" and understand the construction of a role. Fig 2
below presents the tree of "moon".


.. figure:: images/Moon.png
    :alt: Tree of moon role
    :figclass: align-center

    Fig 2. Tree of moon role


There are five directories in moon, which are files, handlers, tasks, templates and vars.
Almost every role has such six directories.

For "defaults", usually a main.yml in this directory is used to store some variables defined
by developers. The variables can be a package url, deployment related parameters,
configurations or package name.

For "files", it is used to store the files you want to copy to the hosts without any
modification. These files can be configuration files, code files and etc. Here in moon's
files directory, there are two python files and one configuration file. All of the three
files will be copied to controller nodes for some purposes.

For "handlers", it is used to store some operations frequently used in your tasks. For
example, restarting a service daemon.

For "tasks", it is used to store the task yaml files. You need to add the yaml files including
the tasks you write to deploy your role on the hosts. Please attention that a *main.yml*
should be existed as the entrance of running tasks. In Fig 2, you can find that there are four
yaml files in the tasks directory of moon. The *main.yml* is the entrance which will call the
other three yaml files.

For "templates", it is used to store the files that you want to replace some variables in them
before copying to hosts. These variables are usually defined in "vars" directory. This can
avoid hard coding.

For "vars", it is used to store the yaml files in which the packages and variables are defined.
The packages defined here are some generic debian or rpm packages. The script of making repo
will scan the packages names here and download them into related PPA. The variables defined
here can be used in the files in "templates", "tasks" and "handlers".

The inventory file is put in "/var/ansible/run/openstack_ocata-opnfv2/inventories/"
on compass-tasks container. You can use any host inventories defined there.

For some settings which need to be defined right before deployment can be put in xxx. Then, they
will be renderred into grup_vars/all in "/var/ansible/run/openstack_ocata-opnfv2/group_vars/all"
on compass-tasks container.

Note: for more about the places where variables should be defined, please read Reference[2].

Adaption with OpenStack
-----------------------

If your feature is not coupling with OpenStack, you can skip this.

If your feature is coupling with OpenStack, we suggest that write your role by following the
rules of OpenStack Ansible. And the inventories used in your role should be defined in the
OAS inventory file which is "/etc/openstack_deploy/openstack_inventory.json" on compass-tasks
container. We don't suggest you define variables in the group_vars/all of compass, cause this
is not stable to render them while using openstack-ansible to play your role. 

Some special scenario, such as ODL. We need to define "odl_l3_agent" right before deployment.
This will be put into group_vars/all of compass like this: 

.. code-block:: bash

    odl_l3_agent: Disable

While running your role by using openstack-ansible, the variable "odl_l3_agent" need to be
transmitted into openstack-ansible. We make it works by defining it in the playbook:

.. code-block:: bash

    - name: run opendaylight role
      hosts: neutron_all | galera_container | network_hosts | repo_container
      gather_facts: "{{ gather_facts | default(True) }}"
      max_fail_percentage: 20
      user: root
      tasks:
        openstack-ansible /opt/openstack-ansible/playbooks/setup-odl.yml
      vars:
        - odl_l3_agent: "{{ odl_l3_agent }}"
      tags:
        - odl

Then this variable will transmitted into OSA.

References
----------

`[1] Ansible documentation: http://docs.ansible.com/ansible/index.html>`
`[2] http://docs.ansible.com/ansible/playbooks_variables.html`

