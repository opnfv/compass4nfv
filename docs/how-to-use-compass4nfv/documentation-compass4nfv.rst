.. two dots create a comment. please leave this logo at the top of each of your rst files.
.. image:: ../etc/opnfv-logo.png 
  :height: 40
  :width: 200
  :alt: OPNFV
  :align: left
.. these two pipes are to seperate the logo from the first title
|
|
Prerequisite
============

  1. One jumpserver installed with Ubuntu14.04.


  2. If baremetal is target installed environment, the jumpserver needs 3 physical ethernet ports, 2 ports(for Managerment/Installation, IPMI) connect with baremetals, 1 ports connects with externel network. Baremetal neets to be same.


  3. Pre-allocate IP addresses for baremetals, and get accounts and passwords of BMC on baremetals.


  4. If virtual machine is target installed environment, the jumpserver also needs 100G storage and 16G RAM.


  5. Gerrit: git clone https://gerrit.opnfv.org/gerrit/compass4nfv


  6. Please don't git clone compass4nfv in the root directory.


  Attention: Compass4nfv does stick on the OPNFV communities' Operating System version requirement. For Brahmputra, Ubuntu14.04 or newer and Centos7.0 or newer are requested, so the target installed environment will be installed on Ubuntu14.04 or Centos7.0.



How to build a ISO
==================

If you want to use official ISO to deploy Compass4nfv, you can jump over this section. 


This section indicates how to add new packages into the compass4nfv iso file and Compass4nfv would install the packages automatically during the deployment.


Aproach 1:


1. Confirm the targeted packages could be installed via apt-get(Ubuntu) and yum(Centos), you can verify on your own environment first by commands "apt-get install {targeted packages}" on Ubuntu and "yum install {targeted packages}" on Centos.


2. Create a new role folder ({newrole}) in the compass4nfv/deploy/adapters/ansible/roles/, create a new folder named "vars" in the new role folder({newrole}), and create a file named "main.yml".


3. If the targeted packages name are same in both Ubuntu and Centos, you just need edit main.yml. 

.. the content:: bash
    ---
    packages_noarch:
       - {targeted packages1}
       - {targeted packages2}
       - {targeted packages3}
       ...


4. If the targeted packages name are different, you need add "Debian.yml" and "RedHat.yml" in the same folder as "main.yml". the content in "Debian.yml" and "RedHat.yml" ::

     packages:
        - {targeted Ubuntu/RedHat  packages1}
        - {targeted Ubuntu/RedHat  packages2}
        - {targeted Ubuntu/RedHat  packages3}
        ...


Also you can refer compass4nfv/deploy/adapters/ansible/roles/glance/vars as example.


5.1 Add the new role: go in compass4nfv/deploy/adapters/ansible/openstack_juno/ and edit HA-ansible-multinodes.yml and/or single-controller.yml, add {newrole} at the position as you want, please be aware of that compass4nfv deploys the roles in the order as mentioned in HA-ansible-multinodes.yml/single-controller.yml, you can add a new section as the following::

     - hosts: all/controller/compute/ha
       remote_user: root
       sudo: True
       roles:
           - {newrole}

the first line of the section means compass4nfv will deploy on which baremetals/VMs, "all" means it deploys on all baremetals/VMs, "controller" means it deploys on all controller and so on.
    
Also you can refer "glance" position in HA-ansible-multinodes.yml and single-controller.yml.

    ::
    Attention
       "HA-ansible-multinodes.yml" deploys controllers backup targeted environment and 3 controllers in backup mode + 2 compute by default; 
       "single-controller.yml" deploys 1 controller + 4 compute.


5.2 Or insert the new role into the existing section in HA-ansible-multinodes.yml and single-controller.yml, also you can refer "glance" position in HA-ansible-multinodes.yml and single-controller.yml.



How to deploy Compass4nfv in virtual machine/baremetal
======================================================




How to integration plugins with Compass4nfv
===========================================




How to deploy Compass4nfv without network access
================================================




The Sphinx Build
================

When you push documentation changes to gerrit a jenkins job will create html documentation.

* Verify Jobs
For verify jobs a link to the documentation will show up as a comment in gerrit for you to see the result.

* Merge jobs

Once you are happy with the look of your documentation you can submit the patchset the merge job will 
copy the output of each documentation directory to http://artifacts.opnfv.org/$project/docs/$name_of_your_folder/index.html

Here are some quick examples of how to use rst markup

This is a headline::

  here is some code, note that it is indented

links are easy to add: Here is a link to sphinx, the tool that we are using to generate documetation http://sphinx-doc.org/

* Bulleted Items

  **this will be bold**

.. code-block:: bash

  echo "Heres is a code block with bash syntax highlighting"


Leave these at the bottom of each of your documents they are used internally

Revision: _sha1_

Build date: |today|
