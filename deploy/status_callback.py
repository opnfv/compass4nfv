##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

import httplib
import json
import sys  # noqa:F401

from ansible.plugins.callback import CallbackBase

COMPASS_HOST = "compass-deck"


# def task_error(display, host, data):
#     display.display("task_error: host=%s,data=%s" % (host, data))
#
#     if isinstance(data, dict):
#         invocation = data.pop('invocation', {})
#
#     notify_host(display, COMPASS_HOST, host, "failed")


class CallbackModule(CallbackBase):
    """
    logs playbook results, per host, in /var/log/ansible/hosts
    """
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'status_callback'
    CALLBACK_NEEDS_WHITELIST = True

    def __init__(self):
        super(CallbackModule, self).__init__()

    def v2_on_any(self, *args, **kwargs):
        pass

    def v2_runner_on_failed(self, res, ignore_errors=False):
        # task_error(self._display, host, res)
        pass

    def v2_runner_on_ok(self, res):
        pass

    def v2_runner_on_skipped(self, host, item=None):
        pass

    def v2_runner_on_unreachable(self, host, res):
        pass

    def v2_runner_on_no_hosts(self):
        pass

    def v2_runner_on_async_poll(self, host, res, jid, clock):
        pass

    def v2_runner_on_async_ok(self, host, res, jid):
        pass

    def v2_runner_on_async_failed(self, host, res, jid):
        # task_error(self._display, host, res)
        pass

    def v2_playbook_on_start(self):
        pass

    def v2_playbook_on_notify(self, host, handler):
        pass

    def v2_playbook_on_no_hosts_matched(self):
        pass

    def v2_playbook_on_no_hosts_remaining(self):
        pass

    def v2_playbook_on_task_start(self, name, is_conditional):
        pass

    def v2_playbook_on_vars_prompt(self, varname, private=True, prompt=None,
                                encrypt=None, confirm=False, salt_size=None, salt=None, default=None):   # noqa
        pass

    def v2_playbook_on_setup(self):
        pass

    def v2_playbook_on_import_for_host(self, host, imported_file):
        pass

    def v2_playbook_on_not_import_for_host(self, host, missing_file):
        pass

    def v2_playbook_on_play_start(self, play):
        self.play = play
        self.loader = self.play.get_loader()
        return

    def v2_playbook_on_stats(self, stats):
        self._display.display("playbook_on_stats enter")
        all_vars = self.play.get_variable_manager().get_vars(self.loader)
        host_vars = all_vars["hostvars"]
        hosts = sorted(stats.processed.keys())
        cluster_name = host_vars[hosts[0]]['cluster_name']

        headers = {"Content-type": "application/json",
                   "Accept": "*/*"}
        conn = httplib.HTTPConnection(COMPASS_HOST, 80)
        token = auth(conn)
        headers["X-Auth-Token"] = token
        get_url = "/api/clusterhosts"
        conn.request("GET", get_url, "", headers)
        resp = conn.getresponse()
        raise_for_status(resp)
        clusterhost_data = json.loads(resp.read())
        clusterhost_mapping = {}
        for item in clusterhost_data:
            if item["clustername"] == cluster_name:
                clusterhost_mapping.update({item["hostname"]:
                                           item["clusterhost_id"]})

        force_error = False
        if "localhost" in hosts:
            summary = stats.summarize("localhost")
            if summary['failures'] > 0 or summary['unreachable'] > 0:
                force_error = True

        for hostname, hostid in clusterhost_mapping.iteritems():
            if hostname not in hosts:
                continue

            summary = stats.summarize(hostname)
            # self._display.display("host: %s \nsummary: %s\n" % (host, summary)) # noqa

            if summary['failures'] > 0 or summary['unreachable'] > 0 \
               or force_error:
                status = "error"
            else:
                status = "succ"
            self._display.display("hostname: %s" % hostname)
            notify_host(self._display, COMPASS_HOST, hostid, status)


def raise_for_status(resp):
    if resp.status < 200 or resp.status > 300:
        raise RuntimeError(
            "%s, %s, %s" %
            (resp.status, resp.reason, resp.read()))


def auth(conn):
    credential = {}
    credential['email'] = "admin@huawei.com"
    credential['password'] = "admin"
    url = "/api/users/token"
    headers = {"Content-type": "application/json",
               "Accept": "*/*"}
    conn.request("POST", url, json.dumps(credential), headers)
    resp = conn.getresponse()

    raise_for_status(resp)
    return json.loads(resp.read())["token"]


def notify_host(display, compass_host, hostid, status):
    url = "/api/clusterhosts/%s/state" % hostid
    if status == "succ":
        body = {"state": "SUCCESSFUL"}
    elif status == "error":
        body = {"state": "ERROR"}
    else:
        display.error("notify_host: hostid %s with status %s is not supported"
                      % (hostid, status))
        return

    headers = {"Content-type": "application/json",
               "Accept": "*/*"}

    conn = httplib.HTTPConnection(compass_host, 80)
    token = auth(conn)
    headers["X-Auth-Token"] = token
    display.display("host=%s,url=%s,body=%s,headers=%s" %
                    (compass_host, url, json.dumps(body), headers))
    conn.request("POST", url, json.dumps(body), headers)
    resp = conn.getresponse()
    try:
        raise_for_status(resp)
        display.display(
            "notify host status success!!! status=%s, body=%s" %
            (resp.status, resp.read()))
    except Exception as e:
        display.error("http request failed %s" % str(e))
        raise
    finally:
        conn.close()
