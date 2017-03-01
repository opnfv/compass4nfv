#!/bin/sh
export LC_ALL=C
export OS_NO_CACHE=true
export OS_TENANT_NAME=nfv
export OS_PROJECT_NAME=nfv
export OS_USERNAME=nfv_user
export OS_PASSWORD=console
export OS_AUTH_URL=http://{{ internal_vip.ip }}:35357/v3
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_AUTH_STRATEGY=keystone
export OS_REGION_NAME=RegionOne
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
