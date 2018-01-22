#!/bin/venv python

import yaml
import sys

compass_bin = "/opt/compass/bin"
sys.path.append(compass_bin)
import switch_virtualenv  # noqa: F401

from ansible.errors import AnsibleError  # noqa: E402
from ansible.plugins.lookup import LookupBase  # noqa: E402


class LookupModule(LookupBase):

    def read_yaml(self, yaml_path, key, default=None):
        if not key:
            return None

        with open(yaml_path) as fd:
            yaml_data = yaml.safe_load(fd)

        if key in yaml_data:
            return yaml_data[key]
        else:
            return default

    def run(self, terms, variables=None, **kwargs):
        res = []
        if not isinstance(terms, list):
            terms = [terms]

        for term in terms:
            params = term.split()
            yaml_path = params[0]

            param_dict = {
                'key': None,
                'default': None
            }

            try:
                for param in params[1:]:
                    key, value = param.split('=')
                    assert(key in param_dict)
                    param_dict[key] = value
            except (AttributeError, AssertionError), e:
                raise AnsibleError(e)

            data = self.read_yaml(yaml_path,
                                  param_dict['key'],
                                  param_dict['default'])
            res.append(data)

        return res
