#!/bin/bash
# Copyright 2017-2018 OPNFV, Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -

source /etc/lsb-release

echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list

apt-get update

apt-get install -y influxdb

sleep 5

# install types.db
mkdir /opt/collectd && mkdir /opt/collectd/share && mkdir /opt/collectd/share/collectd && cd /opt/collectd/share/collectd

wget https://raw.githubusercontent.com/collectd/collectd/master/src/types.db && cd -
