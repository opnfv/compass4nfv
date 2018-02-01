#!/usr/bin/env python
#
# Copyright 2014 Huawei Technologies Co. Ltd
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

"""Ansible playbook callback after a playbook run has completed."""
import sys

from distutils.version import LooseVersion
from ansible import __version__ as __ansible_version__
from ansible.plugins.callback import CallbackBase

compass_bin = "/opt/compass/bin"
sys.path.append(compass_bin)

import switch_virtualenv  # noqa: F401

from compass.apiclient.restful import Client  # noqa: E402
from compass.utils import flags  # noqa: E402


flags.add('compass_server',
          help='compass server url',
          default='http://compass-deck/api')
flags.add('compass_user_email',
          help='compass user email',
          default='admin@huawei.com')
flags.add('compass_user_password',
          help='compass user password',
          default='admin')


class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'playbook_done'
    CALLBACK_NEEDS_WHITELIST = True

    def __init__(self):
        super(CallbackModule, self).__init__()

        self.play = None
        self.loader = None
        self.disabled = False
        try:
            self.client = self._get_client()
        except Exception:
            self.disabled = True
            self._display.error("No compass server found"
                                "disabling this plugin")

    def _get_client(self):
        return Client(flags.OPTIONS.compass_server)

    def _login(self, client):
        """get apiclient token."""
        status, resp = client.get_token(
            flags.OPTIONS.compass_user_email,
            flags.OPTIONS.compass_user_password
        )
        self._display.warning(
            'login status: %s, resp: %s' %
            (status, resp)
        )
        if status >= 400:
            raise Exception(
                'failed to login %s with user %s',
                flags.OPTIONS.compass_server,
                flags.OPTIONS.compass_user_email
            )
        return resp['token']

    def v2_playbook_on_play_start(self, play):
        self.play = play
        self.loader = self.play.get_loader()
        return

    def v2_playbook_on_stats(self, stats):
        if LooseVersion(__ansible_version__) < LooseVersion("2.4"):
            all_vars = self.play.get_variable_manager().get_vars(self.loader)
        else
            all_vars = self.play.get_variable_manager().get_vars()
        host_vars = all_vars["hostvars"]
        hosts = sorted(stats.processed.keys())
        cluster_name = host_vars[hosts[0]]['cluster_name']
        self._display.warning("cluster_name %s" % cluster_name)

        failures = False
        unreachable = False

        for host in hosts:
            summary = stats.summarize(host)

            if summary['failures'] > 0:
                failures = True
            if summary['unreachable'] > 0:
                unreachable = True

        if failures or unreachable:
            return
