##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
cat <<EOT>> /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2_odl]
password = admin
username = admin
url = http://{{ internal_vip.ip }}:8080/controller/nb/v2/neutron
EOT
