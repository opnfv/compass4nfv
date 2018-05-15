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

echo "deb https://packagecloud.io/grafana/stable/debian/ stretch main" | tee /etc/apt/sources.list.d/grafana.list

curl https://packagecloud.io/gpg.key | apt-key add -

apt-get update

apt-get install -y grafana

sleep 5

service grafana-server start
