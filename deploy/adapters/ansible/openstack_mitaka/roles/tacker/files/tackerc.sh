#!/bin/sh
export LC_ALL=C
export OS_NO_CACHE=true
export OS_TENANT_NAME=service
export OS_PROJECT_NAME=service
export OS_USERNAME=tacker
export OS_PASSWORD=console
export OS_AUTH_URL=http://{{ internal_vip.ip }}:5000/v2.0
export OS_DEFAULT_DOMAIN=default
export OS_AUTH_STRATEGY=keystone
export OS_REGION_NAME=RegionOne
export TACKER_ENDPOINT_TYPE=internalurl
