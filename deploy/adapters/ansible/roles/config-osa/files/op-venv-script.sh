##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

#!/usr/local/env bash

set -ev

function venv_create {
    VENV_PATH="$1"
    VENV_FILE="$2"
    ROLE_VENV_WITH_INDEX="$3"
    VENV_VALUES="$4"

    # If the venv working directory already exists remove it
    [[ -d "/tmp/${VENV_PATH}" ]] && rm -rf "/tmp/${VENV_PATH}"

    # If the pip build directory already exists remove it
    [[ -d "/tmp/${VENV_FILE}" ]] && rm -rf "/tmp/${VENV_FILE}"

    # Create the virtualenv shell
    /usr/local/bin/virtualenv --always-copy --extra-search-dir /var/www/repo/os-releases/15.1.4/ubuntu-16.04-x86_64 --never-download "${VENV_PATH}"

    # Create the pip build directory
    mkdir -p "/tmp/${VENV_FILE}"

    # Activate the python virtual environment for good measure
    source "${VENV_PATH}/bin/activate"

    # Run the pip install within the venv and specify a specific build directory which
    #  resolves pip locking issues when run in parallel.
                
    if [ "${ROLE_VENV_WITH_INDEX}" = false ]; then
    ${VENV_PATH}/bin/pip install --build "/tmp/${VENV_FILE}" --timeout 120 --find-links /var/www/repo/os-releases/15.1.4/ubuntu-16.04-x86_64 --log /var/log/repo/repo_venv_builder.log --no-index ${VENV_VALUES}

            
    else
    ${VENV_PATH}/bin/pip install --build "/tmp/${VENV_FILE}" --timeout 120 --find-links /var/www/repo/os-releases/15.1.4/ubuntu-16.04-x86_64 --log /var/log/repo/repo_venv_builder.log ${VENV_VALUES}

    fi

    # Deactivate the venv for good measure
    deactivate

    # Find and remove all of the python pyc files
    find "${VENV_PATH}" -type f -name '*.pyc' -delete

    # Create the archive
    tar czf "${VENV_FILE}.tgz" -C "${VENV_PATH}" .

    # Create a checksum file for the archive
    sha1sum "${VENV_FILE}.tgz" | awk '{print $1}' > "${VENV_FILE}.checksum"

    # Remove the working directories
    rm -rf "${VENV_PATH}"
    rm -rf "/tmp/${VENV_FILE}"
}

# First operation is to sort and set the known os_* roles and create a unique dict.
#  NOTE: this is a Jinja loop and will not be rendered within the script. For debugging
#        purposes the group data will be rendered as a comment.
# venv to build os_glance
#   * packages within the os_glance venv: [u'glance', u'keystonemiddleware', u'os-brick', u'pycrypto', u'pymysql', u'python-cinderclient', u'python-glanceclient', u'python-keystoneclient', u'python-memcached', u'python-swiftclient', u'warlock']
# venv to build os_ceilometer
#   * packages within the os_ceilometer venv: [u'ceilometer', u'ceilometermiddleware', u'gnocchiclient', u'libvirt-python', u'pycrypto', u'pymongo', u'pymysql', u'python-ceilometerclient', u'python-memcached', u'tooz', u'warlock']
# venv to build os_heat
#   * packages within the os_heat venv: [u'heat', u'keystonemiddleware', u'pycrypto', u'pymysql', u'python-ceilometerclient', u'python-cinderclient', u'python-glanceclient', u'python-heatclient', u'python-keystoneclient', u'python-memcached', u'python-neutronclient', u'python-novaclient', u'python-openstackclient', u'python-swiftclient', u'python-troveclient']
# venv to build os_aodh
#   * packages within the os_aodh venv: [u'aodh[mysql]', u'ceilometermiddleware', u'gnocchiclient', u'pycrypto', u'pymysql', u'python-ceilometerclient', u'python-memcached', u'warlock']
# venv to build os_neutron
#   * packages within the os_neutron venv: [u'cliff', u'configobj', u'keystonemiddleware', u'neutron', u'pycrypto', u'pymysql', u'python-glanceclient', u'python-keystoneclient', u'python-memcached', u'python-neutronclient', u'python-novaclient', u'repoze.lru']
# venv to build os_cinder
#   * packages within the os_cinder venv: [u'cinder', u'ecdsa', u'httplib2', u'keystonemiddleware', u'pycrypto', u'pymysql', u'python-cinderclient', u'python-keystoneclient', u'python-memcached']
# venv to build os_tempest
#   * packages within the os_tempest venv: [u'junitxml', u'nose', u'python-ceilometerclient', u'python-cinderclient', u'python-glanceclient', u'python-heatclient', u'python-keystoneclient', u'python-memcached', u'python-neutronclient', u'python-novaclient', u'python-openstackclient', u'python-saharaclient', u'python-subunit', u'python-swiftclient', u'tempest']
# venv to build os_keystone
#   * packages within the os_keystone venv: [u'argparse', u'keystone', u'keystonemiddleware', u'ldappool', u'lxml', u'oslo.log', u'oslo.middleware', u'pbr', u'pycrypto', u'pymysql', u'pysaml2', u'python-keystoneclient', u'python-ldap', u'python-memcached', u'python-openstackclient', u'repoze.lru', u'uwsgi']
# venv to build os_gnocchi
#   * packages within the os_gnocchi venv: [u'gnocchi[mysql,file,swift,ceph]', u'gnocchiclient', u'keystonemiddleware', u'pycrypto', u'python-memcached']
# venv to build os_rally
#   * packages within the os_rally venv: [u'pymysql', u'rally', u'setuptools']
# venv to build os_nova
#   * packages within the os_nova venv: [u'libvirt-python', u'nova-powervm', u'pyasn1-modules', u'keystonemiddleware', u'nova', u'pycrypto', u'pymysql', u'python-keystoneclient', u'python-memcached', u'python-novaclient', u'python-ironicclient', u'uwsgi', u'websockify', u'nova-lxd', u'pylxd', u'pyopenssl']
# venv to build os_horizon
#   * packages within the os_horizon venv: [u'designate_dashboard', u'django-appconf', u'django-openstack-auth', u'greenlet', u'horizon', u'ironic-ui', u'keystonemiddleware', u'magnum-ui', u'mysql-python', u'neutron-lbaas-dashboard', u'oslo.config', u'ply', u'pycrypto', u'pymysql', u'python-keystoneclient', u'python-memcached', u'sahara_dashboard', u'trove_dashboard']

PID=()
# Run the venv create. This will loop over all of the os_group role packages and create a python virtual env.
#  Venv creation is done parallel at a count of the known "ansible_processor_count" or using a default of 5.
#  This loop will enter the venv build directory and create tagged venvs in a distribution directory
#  If the venv archive already exists the creation process will be skipped
pushd "/var/www/repo/venvs/15.1.4/ubuntu-16.04-x86_64"

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/heat"
ROLE_VENV_FILE="heat-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "heat keystonemiddleware pycrypto pymysql python-ceilometerclient python-cinderclient python-glanceclient python-heatclient python-keystoneclient python-memcached python-neutronclient python-novaclient python-openstackclient python-swiftclient python-troveclient" &
    pid[1]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/nova"
ROLE_VENV_FILE="nova-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "libvirt-python nova-powervm pyasn1-modules keystonemiddleware nova pycrypto pymysql python-keystoneclient python-memcached python-novaclient python-ironicclient uwsgi websockify nova-lxd pylxd pyopenssl" &
    pid[2]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/keystone"
ROLE_VENV_FILE="keystone-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "argparse keystone keystonemiddleware ldappool lxml oslo.log oslo.middleware pbr pycrypto pymysql pysaml2 python-keystoneclient python-ldap python-memcached python-openstackclient repoze.lru uwsgi" &
    pid[3]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

#ROLE_VENV_WITH_INDEX=true
#ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/rally"
#ROLE_VENV_FILE="rally-15.1.4-x86_64"
#if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
#    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "pbr pymysql rally setuptools" &
#    pid[4]=$!
#fi
#unset ROLE_VENV_PATH
#unset ROLE_VENV_FILE
#unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/gnocchi"
ROLE_VENV_FILE="gnocchi-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "gnocchi[mysql,file,swift,ceph] gnocchiclient keystonemiddleware pycrypto python-memcached" &
    pid[5]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/aodh"
ROLE_VENV_FILE="aodh-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "aodh[mysql] ceilometermiddleware gnocchiclient pycrypto pymysql python-ceilometerclient python-memcached warlock" &
    pid[6]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/neutron"
ROLE_VENV_FILE="neutron-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "cliff configobj keystonemiddleware neutron pycrypto pymysql python-glanceclient python-keystoneclient python-memcached python-neutronclient python-novaclient repoze.lru" &
    pid[7]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/cinder"
ROLE_VENV_FILE="cinder-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "cinder ecdsa httplib2 keystonemiddleware pycrypto pymysql python-cinderclient python-keystoneclient python-memcached" &
    pid[8]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX
for job_pid in ${!pid[@]}; do
    wait ${pid[$job_pid]} || exit 99
done


ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/glance"
ROLE_VENV_FILE="glance-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "glance keystonemiddleware os-brick pycrypto pymysql python-cinderclient python-glanceclient python-keystoneclient python-memcached python-swiftclient warlock" &
    pid[9]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

#ROLE_VENV_WITH_INDEX=true
#ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/tempest"
#ROLE_VENV_FILE="tempest-15.1.4-x86_64"
#if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
#    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "junitxml nose python-ceilometerclient python-cinderclient python-glanceclient python-heatclient python-keystoneclient python-memcached python-neutronclient python-novaclient python-openstackclient python-saharaclient python-subunit python-swiftclient tempest" &
#    pid[10]=$!
#fi
#unset ROLE_VENV_PATH
#unset ROLE_VENV_FILE
#unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/tacker"
ROLE_VENV_FILE="tacker-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "python-tackerclient mysql-python networking-sfc==4.0.0 pymysql python-heatclient python-tackerclient tacker" &
    pid[3]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/horizon"
ROLE_VENV_FILE="horizon-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "designate_dashboard django-appconf django-openstack-auth greenlet horizon ironic-ui keystonemiddleware magnum-ui mysql-python neutron-lbaas-dashboard oslo.config ply pycrypto pymysql python-keystoneclient python-memcached sahara_dashboard trove_dashboard" &
    pid[11]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX

ROLE_VENV_WITH_INDEX=false
ROLE_VENV_PATH="/tmp/openstack-venv-builder/venvs/ceilometer"
ROLE_VENV_FILE="ceilometer-15.1.4-x86_64"
if [ ! -f "${ROLE_VENV_FILE}.tgz" ];then
    venv_create "${ROLE_VENV_PATH}" "${ROLE_VENV_FILE}" "${ROLE_VENV_WITH_INDEX}" "ceilometer ceilometermiddleware gnocchiclient libvirt-python pycrypto pymongo pymysql python-ceilometerclient python-memcached tooz warlock" &
    pid[12]=$!
fi
unset ROLE_VENV_PATH
unset ROLE_VENV_FILE
unset ROLE_VENV_WITH_INDEX
for job_pid in ${!pid[@]}; do
    wait ${pid[$job_pid]} || exit 99
done

popd

