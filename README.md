##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# Compass4nfv Build Guide

Compass4nfv is an installer project based on open source project COMPASS, which provides automated deployment and management of OpenStack and other distributed systems.

This is a project for running compass4nfv in OPNFV, including build OPNFV imaged-base installation ISO, deployment for OPNFV distributed system.

There are two files in this directory:

* **build**: build imaged-base installation ISO for OPNFV.
* **deploy**: deploy OPNFV distributed system base the above ISO.

There are five directories in this directory:

* **repo**: make repo for building the installation ISO

For the repo directory:

```
|-- constants.py ## set OS of Docker to make repo
|-- features ## feature components of OPNFV
|   |-- brahmaputra ## release name of OPNFV
|   |   |-- make_odl.sh ## script to make ODL package
|   |   `-- make_opencon-trail.sh ## script to make Open-contrail package
|   |-- colorado ## release name of OPNFV
|   |   |-- make_kvmfornfv.sh ## script to make Kvm4nfv package
|   |   |-- make_moon.sh ## script to make Moon package
|   |   |-- make_odl.sh ## script to make ODL package
|   |   |-- make_onos.sh ## script to make ONOS package
|   |   `-- make_opencon-trail.sh ## script to make Open-contrail package
|   |-- danube ## release name of OPNFV
|   |   |-- make_moon.sh ## script to make Moon package
|   |   |-- make_odl.sh ## script to make ODL package
|   |   |-- make_onos.sh ## script to make ONOS package
|   |   `-- make_opencon-trail.sh ## script to make Open-contrail package
|   `-- Dockerfile ## Dockerfile to make feature repo
|-- gen_ins_pkg_script.py ## generate the script of downloading package
|-- jhenv_template ## Dockerfile used for making jumphost related package
|   |-- centos ## arch name
|   |   `-- rhel7 ## OS name
|   |       `-- Dockerfile
|   `-- ubuntu ## arch name
|       |-- trusty ## OS name
|       |   `-- Dockerfile
|       `-- xenial ## OS name
|           `-- Dockerfile
|-- make_repo.sh ## entrance to make repo
|-- openstack ## make openstack package
|   |-- make_ppa ## scripts used to make openstack deb or rpm repo
|   |   |-- centos ## arch
|   |   |   |-- ceph_key_release.asc ## Release repositories use the release.asc key to verify packages.
|   |   |   |-- comps.xml ## used in rpm repo
|   |   |   |-- Dockerfile.tmpl ## Dockerfile running to make repo
|   |   |   `-- rhel7 ## arch
|   |   |       |-- compass ## Make the package used by compass vm
|   |   |       |   `-- download_pkg.tmpl
|   |   |       |-- juno ## package for openstack juno
|   |   |       |   `-- download_pkg.tmpl
|   |   |       |-- kilo ## package for openstack kilo
|   |   |       |   `-- download_pkg.tmpl
|   |   |       |-- liberty ## package for openstack liberty
|   |   |       |   `-- download_pkg.tmpl
|   |   |       `-- mitaka ## package for openstack mitaka
|   |   |           `-- download_pkg.tmpl
|   |   |-- redhat ## Red Hat Enterprise Linux Release
|   |   |   |-- ceph_key_release.asc ## Release repositories use the release.asc key to verify packages
|   |   |   |-- comps.xml ## used in rpm repo
|   |   |   |-- Dockerfile.tmpl ## Dockerfile running to make repo
|   |   |   `-- redhat7 ## OS name
|   |   |       `-- osp9 ## Red Hat OpenStack Platform
|   |   |           `-- download_pkg.tmpl
|   |   `-- ubuntu ## arch
|   |       |-- Dockerfile.tmpl ## Dockerfile running to make repo
|   |       |-- trusty ## OS name
|   |       |   |-- juno ## package for openstack juno
|   |       |   |   `-- download_pkg.tmpl
|   |       |   |-- kilo ## package for openstack kilo
|   |       |   |   `-- download_pkg.tmpl
|   |       |   |-- liberty ## package for openstack liberty
|   |       |   |   `-- download_pkg.tmpl
|   |       |   `-- mitaka ## package for openstack mitaka
|   |       |       `-- download_pkg.tmpl
|   |       `-- xenial ## OS name
|   |           |-- mitaka ## package for openstack mitaka
|   |           |   `-- download_pkg.tmpl
|   |           `-- newton ## package for openstack newton
|   |               `-- download_pkg.tmpl
|   |-- pip ## make pip package according to the requirement.txt openstack source code repo
|   |   |-- code_url.conf ##code url
|   |   `-- Dockerfile
|   `-- special_pkg ## some special packages
|       |-- Debian
|       |   `-- make_openvswitch-switch.sh
|       `-- RedHat
|           |-- make_jdk.sh
|           `-- make_kibana.sh
|-- repo.conf ## configuration file used in making repo
`-- repo_func.sh ## function lib
```

* **build**: configuration file of building is put in this directory.

For the build directory:

```
`-- build.conf ## configuration file used in building ISO
```
