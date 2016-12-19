##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
# Verify the Identity Service installation
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_TENANT_NAME=admin
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD={{ ADMIN_PASS }}
export OS_AUTH_URL=http://{{ internal_vip.ip }}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
