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

if [ -z "${influxdb_host}" ]
then
  influxdb_host=localhost
fi


while [ -z "$RETURN" ]
do
  sleep 1
  RETURN=$(curl -u admin:admin -X POST -H 'content-type: application/json'\
  http://127.0.0.1:3000/api/datasources -d \
  '{"name":"collectd","type":"influxdb","url":"http://'"${influxdb_host}"':8086","access":"proxy","isDefault":true,"database":"collectd","user":"admin","password":"admin","basicAuth":false}')
done

FILES=/opt/barometer/docker/barometer-grafana/dashboards/*.json
for f in $FILES
do
  curl -u admin:admin -X POST -H 'content-type: application/json' \
      http://127.0.0.1:3000/api/dashboards/db -d @$f ;
done
