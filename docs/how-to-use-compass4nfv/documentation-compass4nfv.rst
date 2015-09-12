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


This section indicates how to add new packages and how to build a new compass4nfv iso file so that Compass4nfv would install the packages automatically during the deployment.


* Approach 1 ----- apt/yum installation:


1. Confirm the targeted packages could be installed via apt-get(Ubuntu) and yum(Centos), you can verify on your own environment first by commands "apt-get install {targeted packages}" on Ubuntu and "yum install {targeted packages}" on Centos.


2. Create a new role folder ({newrole}) in the compass4nfv/deploy/adapters/ansible/roles/, create a new folder named "vars" in the new role folder({newrole}), and create a file named "main.yml".


3. If the targeted packages name are same in both Ubuntu and Centos, you just need edit main.yml. 

The content:

.. code-block:: bash

    ---
    packages_noarch:
       - {targeted packages1}
       - {targeted packages2}
       - {targeted packages3}
       ...


4. If the targeted packages name are different, you need add "Debian.yml" and "RedHat.yml" in the same folder as "main.yml". 

The content in "Debian.yml" and "RedHat.yml" :

.. code-block:: bash

     ---
     packages:
        - {targeted Ubuntu/RedHat packages1}
        - {targeted Ubuntu/RedHat packages2}
        - {targeted Ubuntu/RedHat packages3}
        ...


Also you can refer compass4nfv/deploy/adapters/ansible/roles/glance/vars as example.


5.1 Add the new role to ansible so that Compass4nfv will install the packages during the deployment : enter compass4nfv/deploy/adapters/ansible/openstack_juno/ and edit HA-ansible-multinodes.yml and/or single-controller.yml, add {newrole} at an appropriate position, please be aware of that compass4nfv deploys the roles in the order as list in HA-ansible-multinodes.yml/single-controller.yml, you can add a new section as the following::

     - hosts: all/controller/compute/ha
       remote_user: root
       sudo: True
       roles:
           - {newrole}

The first line "hosts" of the section means compass4nfv will deploy {newrole} on which baremetals/VMs, "all" means it deploys on all baremetals/VMs, "controller" means it deploys on all controller and so on.
    
Also you can refer "glance" position in HA-ansible-multinodes.yml and single-controller.yml.


Attention
    "HA-ansible-multinodes.yml" deploys controllers backup targeted environment and 3 controllers in backup mode + 2 compute by default;.
    "single-controller.yml" deploys 1 controller + 4 compute.


5.2 Or insert the new role into the existing section at an appropriate position in HA-ansible-multinodes.yml and single-controller.yml.

    Example:
.. code-block:: bash

    - hosts: controller/all/compute/ha
      remote_user: root
      sudo: True
      roles:
        - database
        - mq
        - keystone
        - nova-controller
        - neutron-controller
        - {newrole}

Please pay attention to the first line "hosts" by which Compass4nfv deploys {newrole} on which baremetals/VMs.

Also please pay attention to the position inserted as Compass4nfv deploys the packages in the order as list.

Also you can refer "glance" position as example in HA-ansible-multinodes.yml and single-controller.yml.


6. Run compass4nfv/build/make_repo.sh.


7. After 6 finishs, please check "compass4nfv/work/repo/" folder, if files as following exist in the folder, that means building packages successfully.

centos7-juno-ppa.tar.gz is OpenStack Juno version for Centos7.

trusty-juno-ppa.tar.gz is OpenStack Juno version for Ubuntu14.04.

trusty-kilo-ppa.tar.gz is OpenStack Kilo version for Ubuntu14.04.


8. Edit compass4nfv/build/build.conf, find CENTOS7_JUNO_PPA and TRUSTY_JUNO_PPA items, modify these 2 items as local paths(if you just want deploy with one operating system, you just modify one item).

CENTOS7_JUNO_PPA is packages path for Centos, TRUSTY_JUNO_PPA is packages path for Ubuntu

.. code-block:: bash

    CENTOS7_JUNO_PPA=/compass4nfv/work/repo/centos7-juno-ppa.tar.gz

    TRUSTY_JUNO_PPA=/compass4nfv/work/repo/trusty-juno-ppa.tar.gz


9. Run compass4nfv/build.sh to build a new ISO, after finished, if there is a new ISO file compass.iso in the "compass4nfv/work/building" folder, that means building iso successfully.




* Approach 2 ---- source installation


This section indicates to install packages from source codes. If the installing packages could not be installed from apt-get and yum but from source codes, please refer this section.


1. Enter compass4nfv/build/arch/Debian or compass4nfv/build/arch/RedHat depend on which operating system you want to install package, create a bash(.sh) file which includes all the commands which install the packages from source codes.

   Example:

.. code-block:: bash

    #!/bin/bash
    apt-get update
    apt-get install -y build-essential fakeroot debhelper \
             autoconf automake bzip2 libssl-dev \
             openssl graphviz python-all procps \
             python-qt4 python-zopeinterface \
             python-twisted-conch libtool wget

    pushd .
    cd /tmp
    wget http://openvswitch.org/releases/openvswitch-2.3.1.tar.gz
    tar -zxvf openvswitch-2.3.1.tar.gz
    cd openvswitch-2.3.1
    DEB_BUILD_OPTIONS='parallel=8 nocheck' fakeroot debian/rules binary
    cd -
    cp -f *.deb /var/cache/apt/archives/
    popd

Please pay attention to the last second sentence, all the compiled packages need to be copied to the "/var/cache/apt/archives/"(Ubuntu) folder, and for Centos, the folder is ... to be continued .


2. Add a new role so that Compass4nfv will install the packages during the deployment, create a new role folder ({newrole}) in the compass4nfv/deploy/adapters/ansible/roles/, create a new folder named "vars" in the new role folder({newrole}), and create a file named "main.yml".


3. If the packages name are same in both Ubuntu and Centos, you just need edit main.yml. 

   the content:

.. code-block:: bash

    ---
    packages_noarch:
       - {targeted packages1}
       - {targeted packages2}
       - {targeted packages3}
       ...


4. If the packages name are different, you need add "Debian.yml" and "RedHat.yml" in the same folder as "main.yml". 

The content in "Debian.yml" and "RedHat.yml" :

.. code-block:: bash

     ---
     packages:
        - {targeted Ubuntu/RedHat packages1}
        - {targeted Ubuntu/RedHat packages2}
        - {targeted Ubuntu/RedHat packages3}
        ...


Also you can refer compass4nfv/deploy/adapters/ansible/roles/glance/vars as example.


5.1 Enter compass4nfv/deploy/adapters/ansible/openstack_juno/ and edit HA-ansible-multinodes.yml and/or single-controller.yml, add {newrole} at an appropriate position, please be aware of that compass4nfv deploys the roles in the order as list in HA-ansible-multinodes.yml/single-controller.yml, you can add a new section as the following::

     - hosts: all/controller/compute/ha
       remote_user: root
       sudo: True
       roles:
           - {newrole}

The first line "hosts" of the section means compass4nfv will deploy {newrole} on which baremetals/VMs, "all" means it deploys on all baremetals/VMs, "controller" means it deploys on all controller and so on.
    
Also you can refer "glance" position in HA-ansible-multinodes.yml and single-controller.yml.


Attention
    "HA-ansible-multinodes.yml" deploys controllers backup targeted environment and 3 controllers in backup mode + 2 compute by default.
    "single-controller.yml" deploys 1 controller + 4 compute.


5.2 Or insert the new role into the existing section at an appropriate position in HA-ansible-multinodes.yml and single-controller.yml.

    Example:
.. code-block:: bash

    - hosts: controller
      remote_user: root
      sudo: True
      roles:
        - database
        - mq
        - keystone
        - nova-controller
        - neutron-controller
        - {newrole}

Please pay attention to the first line "hosts" by which Compass4nfv deploys {newrole} on which baremetals/VMs.

Also please pay attention to the position inserted as Compass4nfv deploys the packages in the order as list.

Also you can refer "glance" position as example in HA-ansible-multinodes.yml and single-controller.yml.



6. Run compass4nfv/build/make_repo.sh .



7. After 6 finishs, please check "compass4nfv/work/repo/" folder, if files as following exist in the folder, that means building packages successfully.

centos7-juno-ppa.tar.gz is OpenStack Juno version for Centos7.

trusty-juno-ppa.tar.gz is OpenStack Juno version for Ubuntu14.04.

trusty-kilo-ppa.tar.gz is OpenStack Kilo version for Ubuntu14.04.



8. Edit compass4nfv/build/build.conf, find CENTOS7_JUNO_PPA and TRUSTY_JUNO_PPA items, modify these 2 items as local paths(if you just want deploy with one operating system, you just modify one item).

CENTOS7_JUNO_PPA is packages path for Centos, TRUSTY_JUNO_PPA is packages path for Ubuntu

.. code-block:: bash

    CENTOS7_JUNO_PPA=/compass4nfv/work/repo/centos7-juno-ppa.tar.gz

    TRUSTY_JUNO_PPA=/compass4nfv/work/repo/trusty-juno-ppa.tar.gz



9. Run compass4nfv/build.sh to build a new ISO, after finished, if there is a new ISO file compass.iso in the "compass4nfv/work/building" folder, that means building iso successfully.



* Approach 3 ---- autonomous packages installation 

package installed, to be continued...



How to deploy baremetal and VMs
===============================


* Deploy baremetal in HA mode:


1. (optional) If you have built a new ISO before and want to use the new ISO, please edit compass4nfv/deploy/conf/base.conf file, modify the item "ISO_URL" as export ISO_URL=file:///compass4nfv/work/building/compass.iso


2. Edit compass4nfv/deploy/conf/baremetal_cluster_general.yml, to be continued...


3. Edit compass4nfv/deploy/conf/base.conf, modify the item "export OM_NIC=${OM_NIC:-eth3}" as the install network ethernet port based your jumpserver.


4. Run compass4nfv/deploy.sh baremetal_cluster_general




* Deploy baremetal in Single mode:


1. (optional) If you have built a new ISO before and want to use the new ISO, please edit compass4nfv/deploy/conf/base.conf file, modify the item "ISO_URL" as export ISO_URL=file:///compass4nfv/work/building/compass.iso


2. Edit compass4nfv/deploy/conf/baremetal_five.yml , change items [name, mac, ipmiUser, ipmiPass, ipmiIp, roles] based on the baremetal to be deployed.


3. Edit compass4nfv/deploy/conf/base.conf, modify the item "export OM_NIC=${OM_NIC:-eth3}" as the install network ethernet port based your jumpserver.


4. Run compass4nfv/deploy.sh baremetal_five




* Deploy VMs in HA mode:


1. (optional) If you have built a new ISO before and want to use the new ISO, please edit compass4nfv/deploy/conf/base.conf file, modify the item "ISO_URL" as export ISO_URL=file:///compass4nfv/work/building/compass.iso


2. (Optional) Edit compass4nfv/deploy/conf/virtual_cluster.yml, change items [name, roles] as you want, also you could reduce or add hosts sections as you want. And 3 controller in HA mode and 2 compute will be deployed without changing this yml file.


3. Run compass4nfv/deploy.sh virtual_cluster  or  Run compass4nfv/deploy.sh .




* Deploy baremetal in Single mode:


1. (optional) If you have built a new ISO before and want to use the new ISO, please edit compass4nfv/deploy/conf/base.conf file, modify the item "ISO_URL" as export ISO_URL=file:///compass4nfv/work/building/compass.iso


2. (Optional) Edit compass4nfv/deploy/conf/virtual_five.yml, change items [name, roles] as you want, also you could reduce or add hosts sections as you want. And 3 controller in HA mode and 2 compute will be deployed without changing this yml file.


3. Run compass4nfv/deploy.sh virtual_five .


Attention:
Roles here includes controller compute network storage ha odl and onos.





How to deploy without internet access
=====================================

If you have created your own ISO file(compass.iso), you realy could deploy without internet access, what you need to do is to edit compass4nfv/deploy/conf/base.conf file and assign item ISO_URL as your local path (export ISO_URL=file:///compass4nfv/work/building/compass.iso). Then Compass4nfv could deploy via local compass.iso without internet access.


Except this, also you can download compass.iso first, you get compass.iso location in internet from "compass4nfv/deploy/conf/base.conf" file "ISO_URL" item.

.. code-block:: bash
    export ISO_URL=${ISO_URL:-http://58.251.166.184:9999/compass.iso}

You can use wget command to download compass.iso in the same location as Compass4nfv, and modify "ISO_URL" item in "compass4nfv/deploy/conf/base.conf" file as the downloaded compass.iso location.





How to integration plugins
==========================









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
