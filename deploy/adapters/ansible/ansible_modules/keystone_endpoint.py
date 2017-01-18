#!/usr/bin/python
#
# Copyright 2017 Huawei Technologies Co. Ltd
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

try:
    import shade
    HAS_SHADE = True
except ImportError:
    HAS_SHADE = False

from distutils.version import StrictVersion
from ansible.module_utils.basic import *  # noqa: F403
from ansible.module_utils.openstack import *  # noqa: F403

ANSIBLE_METADATA = {'status': ['preview'],
                    'supported_by': 'community',
                    'version': '1.0'}

DOCUMENTATION = '''
---
module: keystone_endpoint
short_description: Manage OpenStack endpoint
extends_documentation_fragment: openstack
author: "Yuenan Li"
version_added: "2.2"
description:
    - Create, update, or delete OpenStack endpoint.
options:
   name:
     description:
        - Name of the endpoint
     required: true
   service_type:
     description:
        - The type of service
     required: true
   enabled:
     description:
        - Is the endpoint enabled
     required: false
     default: True
   interface:
     description:
        - Interface type of the endpoint
     required: false
   url:
     description:
        - URL of the endpoint
     required: true
   region:
     description:
       - Endpoint region
   state:
     description:
       - Should the resource be present or absent
     choices: [present, absent]
     default: present
requirements:
    - "python >= 2.6"
    - "shade"
'''

EXAMPLES = '''
# Create a endpoint for glance
- keystone_endpoint:
     cloud: mycloud
     state: present
     name: glance
     admin_url: http://172.16.1.222:9292
     internal_url: http://172.16.1.222:9292
     public_url: http://172.16.1.222:9292
'''

RETURN = '''
endpoint:
    description: Dictionary describing the endpoint.
    returned: On success when state is 'present'
    type: dictionary
    contains:
        id:
            description: endpoint ID.
            type: string
            sample: "3292f020780b4d5baf27ff7e1d224c44"
        name:
            description: endpoint name.
            type: string
            sample: "glance"
        interface:
            description: Interface type.
            type: string
            sample: "admin"
        url:
            description: URL.
            type: string
            sample: "http://172.16.1.222:9292"
id:
    description: The endpoint ID.
    returned: On success when state is 'present'
    type: string
    sample: "3292f020780b4d5baf27ff7e1d224c44"
'''


def _needs_update(module, endpoint):
    if endpoint.url != module.params['url'] and \
       endpoint.interface == module.params['interface']:
        return True
    return False


def _system_state_change(module, endpoint):
    state = module.params['state']
    if state == 'absent' and endpoint:
        return True

    if state == 'present':
        if endpoint is None:
            return True
        return _needs_update(module, endpoint)

    return False


def main():
    argument_spec = openstack_full_argument_spec(  # noqa: F405
        enabled=dict(default=True, type='bool'),
        name=dict(required=True),
        service_type=dict(required=True),
        state=dict(default='present', choices=['absent', 'present']),
        region=dict(default=None, required=False),
        interface=dict(default=None,
                       choices=['admin', 'internal', 'public']),
        url=dict(default=None, required=False),
    )

    module_kwargs = openstack_module_kwargs()  # noqa: F405
    module = AnsibleModule(argument_spec,  # noqa: F405
                           supports_check_mode=True,
                           **module_kwargs)

    if not HAS_SHADE:
        module.fail_json(msg='shade is required for this module')
    if StrictVersion(shade.__version__) < StrictVersion('1.6.0'):
        module.fail_json(msg="To utilize this module, the installed version of"
                             "the shade library MUST be >=1.6.0")

    enabled = module.params['enabled']  # noqa: F841
    name = module.params['name']
    service_type = module.params['service_type']
    state = module.params['state']
    region = module.params['region']
    interface = module.params['interface']
    url = module.params['url']

    try:
        cloud = shade.operator_cloud(**module.params)

        services = cloud.search_services(name_or_id=name,
                                         filters=dict(type=service_type))

        if len(services) > 1:
            module.fail_json(msg='Service name %s and type %s are not unique' %
                             (name, service_type))
        elif len(services) == 0:
            module.fail_json(msg="No services with name %s" % name)
        else:
            service = services[0]

        endpoints = [x for x in cloud.list_endpoints()
                     if (x.service_id == service.id and
                         x.interface == interface)]

        count = len(endpoints)
        if count > 1:
            module.fail_json(msg='%d endpoints with service name %s' %
                             (count, name))
        elif count == 0:
            endpoint = None
        else:
            endpoint = endpoints[0]

        if module.check_mode:
            module.exit_json(changed=_system_state_change(module, endpoint))

        if state == 'present':
            if endpoint is None:
                endpoint = cloud.create_endpoint(
                    service_name_or_id=service.id, enabled=enabled,
                    region=region, interface=interface, url=url)
                changed = True
            else:
                if _needs_update(module, endpoint):
                    endpoint = cloud.update_endpoint(
                        endpoint_id=endpoint.id, enabled=enabled,
                        service_name_or_id=service.id, region=region,
                        interface=interface, url=url)
                    changed = True
                else:
                    changed = False
            module.exit_json(changed=changed, endpoint=endpoint)

        elif state == 'absent':
            if endpoint is None:
                changed = False
            else:
                cloud.delete_endpoint(endpoint.id)
                changed = True
            module.exit_json(changed=changed)

    except shade.OpenStackCloudException as e:
        module.fail_json(msg=str(e))


if __name__ == '__main__':
    main()
