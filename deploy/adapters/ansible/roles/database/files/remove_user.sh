##############################################################################
# Copyright (c) 2016 grakiss.wanglei@huawei.com and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
#!/bin/sh
mysql -uroot -Dmysql <<EOF
use mysql;
delete from user where user='';
EOF
