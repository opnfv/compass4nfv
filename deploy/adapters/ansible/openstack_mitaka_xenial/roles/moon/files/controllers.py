# Copyright 2015 Open Platform for NFV Project, Inc. and its contributors
# This software is distributed under the terms and conditions of the 'Apache-2.0'
# license which can be found in the file 'LICENSE' in this package distribution
# or at 'http://www.apache.org/licenses/LICENSE-2.0'.

from keystone.common import controller
from keystone import config
from keystone import exception
from keystone.models import token_model
from keystone.contrib.moon.exception import *
from oslo_log import log
from uuid import uuid4
import requests


CONF = config.CONF
LOG = log.getLogger(__name__)


@dependency.requires('configuration_api')
class Configuration(controller.V3Controller):
    collection_name = 'configurations'
    member_name = 'configuration'

    def __init__(self):
        super(Configuration, self).__init__()

    def _get_user_id_from_token(self, token_id):
        response = self.token_provider_api.validate_token(token_id)
        token_ref = token_model.KeystoneToken(token_id=token_id, token_data=response)
        return token_ref.get('user')

    @controller.protected()
    def get_policy_templates(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        return self.configuration_api.get_policy_templates_dict(user_id)

    @controller.protected()
    def get_aggregation_algorithms(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        return self.configuration_api.get_aggregation_algorithms_dict(user_id)

    @controller.protected()
    def get_sub_meta_rule_algorithms(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        return self.configuration_api.get_sub_meta_rule_algorithms_dict(user_id)


@dependency.requires('tenant_api', 'resource_api')
class Tenants(controller.V3Controller):

    def __init__(self):
        super(Tenants, self).__init__()

    def _get_user_id_from_token(self, token_id):
        response = self.token_provider_api.validate_token(token_id)
        token_ref = token_model.KeystoneToken(token_id=token_id, token_data=response)
        return token_ref.get('user')

    @controller.protected()
    def get_tenants(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        return self.tenant_api.get_tenants_dict(user_id)

    def __get_keystone_tenant_dict(self, tenant_id="", tenant_name="", tenant_description="", domain="default"):
        tenants = self.resource_api.list_projects()
        for tenant in tenants:
            if tenant_id and tenant_id == tenant['id']:
                return tenant
            if tenant_name and tenant_name == tenant['name']:
                return tenant
        if not tenant_id:
            tenant_id = uuid4().hex
        if not tenant_name:
            tenant_name = tenant_id
        tenant = {
            "id": tenant_id,
            "name": tenant_name,
            "description": tenant_description,
            "enabled": True,
            "domain_id": domain
        }
        keystone_tenant = self.resource_api.create_project(tenant["id"], tenant)
        return keystone_tenant

    @controller.protected()
    def add_tenant(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        k_tenant_dict = self.__get_keystone_tenant_dict(
            tenant_name=kw.get('tenant_name'),
            tenant_description=kw.get('tenant_description', kw.get('tenant_name')),
            domain=kw.get('tenant_domain', "default"),

        )
        tenant_dict = dict()
        tenant_dict['id'] = k_tenant_dict['id']
        tenant_dict['name'] = kw.get('tenant_name', None)
        tenant_dict['description'] = kw.get('tenant_description', None)
        tenant_dict['intra_authz_extension_id'] = kw.get('tenant_intra_authz_extension_id', None)
        tenant_dict['intra_admin_extension_id'] = kw.get('tenant_intra_admin_extension_id', None)
        return self.tenant_api.add_tenant_dict(user_id, tenant_dict['id'], tenant_dict)

    @controller.protected()
    def get_tenant(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        tenant_id = kw.get('tenant_id', None)
        return self.tenant_api.get_tenant_dict(user_id, tenant_id)

    @controller.protected()
    def del_tenant(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        tenant_id = kw.get('tenant_id', None)
        return self.tenant_api.del_tenant(user_id, tenant_id)

    @controller.protected()
    def set_tenant(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        # Next line will raise an error if tenant doesn't exist
        k_tenant_dict = self.resource_api.get_project(kw.get('tenant_id', None))
        tenant_id = kw.get('tenant_id', None)
        tenant_dict = dict()
        tenant_dict['name'] = k_tenant_dict.get('name', None)
        if 'tenant_description' in kw:
            tenant_dict['description'] = kw.get('tenant_description', None)
        if 'tenant_intra_authz_extension_id' in kw:
            tenant_dict['intra_authz_extension_id'] = kw.get('tenant_intra_authz_extension_id', None)
        if 'tenant_intra_admin_extension_id' in kw:
            tenant_dict['intra_admin_extension_id'] = kw.get('tenant_intra_admin_extension_id', None)
        self.tenant_api.set_tenant_dict(user_id, tenant_id, tenant_dict)


def callback(self, context, prep_info, *args, **kwargs):
    token_ref = ""
    if context.get('token_id') is not None:
        token_ref = token_model.KeystoneToken(
            token_id=context['token_id'],
            token_data=self.token_provider_api.validate_token(
                context['token_id']))
    if not token_ref:
        raise exception.Unauthorized


@dependency.requires('authz_api')
class Authz_v3(controller.V3Controller):

    def __init__(self):
        super(Authz_v3, self).__init__()

    @controller.protected(callback)
    def get_authz(self, context, tenant_id, subject_k_id, object_name, action_name):
        try:
            return self.authz_api.authz(tenant_id, subject_k_id, object_name, action_name)
        except Exception as e:
            return {'authz': False, 'comment': unicode(e)}


@dependency.requires('admin_api', 'root_api')
class IntraExtensions(controller.V3Controller):
    collection_name = 'intra_extensions'
    member_name = 'intra_extension'

    def __init__(self):
        super(IntraExtensions, self).__init__()

    def _get_user_id_from_token(self, token_id):
        response = self.token_provider_api.validate_token(token_id)
        token_ref = token_model.KeystoneToken(token_id=token_id, token_data=response)
        return token_ref.get('user')['id']

    # IntraExtension functions
    @controller.protected()
    def get_intra_extensions(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        return self.admin_api.get_intra_extensions_dict(user_id)

    @controller.protected()
    def add_intra_extension(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_dict = dict()
        intra_extension_dict['name'] = kw.get('intra_extension_name', None)
        intra_extension_dict['model'] = kw.get('intra_extension_model', None)
        intra_extension_dict['genre'] = kw.get('intra_extension_genre', None)
        intra_extension_dict['description'] = kw.get('intra_extension_description', None)
        intra_extension_dict['subject_categories'] = kw.get('intra_extension_subject_categories', dict())
        intra_extension_dict['object_categories'] = kw.get('intra_extension_object_categories', dict())
        intra_extension_dict['action_categories'] = kw.get('intra_extension_action_categories', dict())
        intra_extension_dict['subjects'] = kw.get('intra_extension_subjects', dict())
        intra_extension_dict['objects'] = kw.get('intra_extension_objects', dict())
        intra_extension_dict['actions'] = kw.get('intra_extension_actions', dict())
        intra_extension_dict['subject_scopes'] = kw.get('intra_extension_subject_scopes', dict())
        intra_extension_dict['object_scopes'] = kw.get('intra_extension_object_scopes', dict())
        intra_extension_dict['action_scopes'] = kw.get('intra_extension_action_scopes', dict())
        intra_extension_dict['subject_assignments'] = kw.get('intra_extension_subject_assignments', dict())
        intra_extension_dict['object_assignments'] = kw.get('intra_extension_object_assignments', dict())
        intra_extension_dict['action_assignments'] = kw.get('intra_extension_action_assignments', dict())
        intra_extension_dict['aggregation_algorithm'] = kw.get('intra_extension_aggregation_algorithm', dict())
        intra_extension_dict['sub_meta_rules'] = kw.get('intra_extension_sub_meta_rules', dict())
        intra_extension_dict['rules'] = kw.get('intra_extension_rules', dict())
        ref = self.admin_api.load_intra_extension_dict(user_id, intra_extension_dict=intra_extension_dict)
        return self.admin_api.populate_default_data(ref)

    @controller.protected()
    def get_intra_extension(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_intra_extension_dict(user_id, intra_extension_id)

    @controller.protected()
    def del_intra_extension(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        self.admin_api.del_intra_extension(user_id, intra_extension_id)

    @controller.protected()
    def set_intra_extension(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        intra_extension_dict = dict()
        intra_extension_dict['name'] = kw.get('intra_extension_name', None)
        intra_extension_dict['model'] = kw.get('intra_extension_model', None)
        intra_extension_dict['genre'] = kw.get('intra_extension_genre', None)
        intra_extension_dict['description'] = kw.get('intra_extension_description', None)
        return self.admin_api.set_intra_extension_dict(user_id, intra_extension_id, intra_extension_dict)

    @controller.protected()
    def load_root_intra_extension(self, context, **kw):
        self.root_api.load_root_intra_extension_dict()

    # Metadata functions
    @controller.protected()
    def get_subject_categories(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_subject_categories_dict(user_id, intra_extension_id)

    @controller.protected()
    def add_subject_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_dict = dict()
        subject_category_dict['name'] = kw.get('subject_category_name', None)
        subject_category_dict['description'] = kw.get('subject_category_description', None)
        return self.admin_api.add_subject_category_dict(user_id, intra_extension_id, subject_category_dict)

    @controller.protected()
    def get_subject_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        return self.admin_api.get_subject_category_dict(user_id, intra_extension_id, subject_category_id)

    @controller.protected()
    def del_subject_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        self.admin_api.del_subject_category(user_id, intra_extension_id, subject_category_id)

    @controller.protected()
    def set_subject_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        subject_category_dict = dict()
        subject_category_dict['name'] = kw.get('subject_category_name', None)
        subject_category_dict['description'] = kw.get('subject_category_description', None)
        return self.admin_api.set_subject_category_dict(user_id, intra_extension_id, subject_category_id, subject_category_dict)

    @controller.protected()
    def get_object_categories(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_object_categories_dict(user_id, intra_extension_id)

    @controller.protected()
    def add_object_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_dict = dict()
        object_category_dict['name'] = kw.get('object_category_name', None)
        object_category_dict['description'] = kw.get('object_category_description', None)
        return self.admin_api.add_object_category_dict(user_id, intra_extension_id, object_category_dict)

    @controller.protected()
    def get_object_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        return self.admin_api.get_object_categories_dict(user_id, intra_extension_id, object_category_id)

    @controller.protected()
    def del_object_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        self.admin_api.del_object_category(user_id, intra_extension_id, object_category_id)

    @controller.protected()
    def set_object_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        object_category_dict = dict()
        object_category_dict['name'] = kw.get('object_category_name', None)
        object_category_dict['description'] = kw.get('object_category_description', None)
        return self.admin_api.set_object_category_dict(user_id, intra_extension_id, object_category_id, object_category_dict)

    @controller.protected()
    def get_action_categories(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_action_categories_dict(user_id, intra_extension_id)

    @controller.protected()
    def add_action_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_dict = dict()
        action_category_dict['name'] = kw.get('action_category_name', None)
        action_category_dict['description'] = kw.get('action_category_description', None)
        return self.admin_api.add_action_category_dict(user_id, intra_extension_id, action_category_dict)

    @controller.protected()
    def get_action_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        return self.admin_api.get_action_categories_dict(user_id, intra_extension_id, action_category_id)

    @controller.protected()
    def del_action_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        self.admin_api.del_action_category(user_id, intra_extension_id, action_category_id)

    @controller.protected()
    def set_action_category(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        action_category_dict = dict()
        action_category_dict['name'] = kw.get('action_category_name', None)
        action_category_dict['description'] = kw.get('action_category_description', None)
        return self.admin_api.set_action_category_dict(user_id, intra_extension_id, action_category_id, action_category_dict)

    # Perimeter functions
    @controller.protected()
    def get_subjects(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_subjects_dict(user_id, intra_extension_id)

    @controller.protected()
    def add_subject(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_dict = dict()
        subject_dict['name'] = kw.get('subject_name', None)
        subject_dict['description'] = kw.get('subject_description', None)
        subject_dict['password'] = kw.get('subject_password', None)
        subject_dict['email'] = kw.get('subject_email', None)
        return self.admin_api.add_subject_dict(user_id, intra_extension_id, subject_dict)

    @controller.protected()
    def get_subject(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_id = kw.get('subject_id', None)
        return self.admin_api.get_subject_dict(user_id, intra_extension_id, subject_id)

    @controller.protected()
    def del_subject(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_id = kw.get('subject_id', None)
        self.admin_api.del_subject(user_id, intra_extension_id, subject_id)

    @controller.protected()
    def set_subject(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_id = kw.get('subject_id', None)
        subject_dict = dict()
        subject_dict['name'] = kw.get('subject_name', None)
        subject_dict['description'] = kw.get('subject_description', None)
        return self.admin_api.set_subject_dict(user_id, intra_extension_id, subject_id, subject_dict)

    @controller.protected()
    def get_objects(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_objects_dict(user_id, intra_extension_id)

    @controller.protected()
    def add_object(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_dict = dict()
        object_dict['name'] = kw.get('object_name', None)
        object_dict['description'] = kw.get('object_description', None)
        return self.admin_api.add_object_dict(user_id, intra_extension_id, object_dict)

    @controller.protected()
    def get_object(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_id = kw.get('object_id', None)
        return self.admin_api.get_object_dict(user_id, intra_extension_id, object_id)

    @controller.protected()
    def del_object(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_id = kw.get('object_id', None)
        self.admin_api.del_object(user_id, intra_extension_id, object_id)

    @controller.protected()
    def set_object(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_id = kw.get('object_id', None)
        object_dict = dict()
        object_dict['name'] = kw.get('object_name', None)
        object_dict['description'] = kw.get('object_description', None)
        return self.admin_api.set_object_dict(user_id, intra_extension_id, object_id, object_dict)

    @controller.protected()
    def get_actions(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_actions_dict(user_id, intra_extension_id)

    @controller.protected()
    def add_action(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_dict = dict()
        action_dict['name'] = kw.get('action_name', None)
        action_dict['description'] = kw.get('action_description', None)
        return self.admin_api.add_action_dict(user_id, intra_extension_id, action_dict)

    @controller.protected()
    def get_action(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_id = kw.get('action_id', None)
        return self.admin_api.get_action_dict(user_id, intra_extension_id, action_id)

    @controller.protected()
    def del_action(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_id = kw.get('action_id', None)
        self.admin_api.del_action(user_id, intra_extension_id, action_id)

    @controller.protected()
    def set_action(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_id = kw.get('action_id', None)
        action_dict = dict()
        action_dict['name'] = kw.get('action_name', None)
        action_dict['description'] = kw.get('action_description', None)
        return self.admin_api.set_action_dict(user_id, intra_extension_id, action_id, action_dict)

    # Scope functions
    @controller.protected()
    def get_subject_scopes(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        return self.admin_api.get_subject_scopes_dict(user_id, intra_extension_id, subject_category_id)

    @controller.protected()
    def add_subject_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        subject_scope_dict = dict()
        subject_scope_dict['name'] = kw.get('subject_scope_name', None)
        subject_scope_dict['description'] = kw.get('subject_scope_description', None)
        return self.admin_api.add_subject_scope_dict(user_id, intra_extension_id, subject_category_id, subject_scope_dict)

    @controller.protected()
    def get_subject_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        subject_scope_id = kw.get('subject_scope_id', None)
        return self.admin_api.get_subject_scope_dict(user_id, intra_extension_id, subject_category_id, subject_scope_id)

    @controller.protected()
    def del_subject_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        subject_scope_id = kw.get('subject_scope_id', None)
        self.admin_api.del_subject_scope(user_id, intra_extension_id, subject_category_id, subject_scope_id)

    @controller.protected()
    def set_subject_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        subject_scope_id = kw.get('subject_scope_id', None)
        subject_scope_dict = dict()
        subject_scope_dict['name'] = kw.get('subject_scope_name', None)
        subject_scope_dict['description'] = kw.get('subject_scope_description', None)
        return self.admin_api.set_subject_scope_dict(user_id, intra_extension_id, subject_category_id, subject_scope_id, subject_scope_dict)

    @controller.protected()
    def get_object_scopes(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        return self.admin_api.get_object_scopes_dict(user_id, intra_extension_id, object_category_id)

    @controller.protected()
    def add_object_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        object_scope_dict = dict()
        object_scope_dict['name'] = kw.get('object_scope_name', None)
        object_scope_dict['description'] = kw.get('object_scope_description', None)
        return self.admin_api.add_object_scope_dict(user_id, intra_extension_id, object_category_id, object_scope_dict)

    @controller.protected()
    def get_object_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        object_scope_id = kw.get('object_scope_id', None)
        return self.admin_api.get_object_scope_dict(user_id, intra_extension_id, object_category_id, object_scope_id)

    @controller.protected()
    def del_object_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        object_scope_id = kw.get('object_scope_id', None)
        self.admin_api.del_object_scope(user_id, intra_extension_id, object_category_id, object_scope_id)

    @controller.protected()
    def set_object_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_category_id = kw.get('object_category_id', None)
        object_scope_id = kw.get('object_scope_id', None)
        object_scope_dict = dict()
        object_scope_dict['name'] = kw.get('object_scope_name', None)
        object_scope_dict['description'] = kw.get('object_scope_description', None)
        return self.admin_api.set_object_scope_dict(user_id, intra_extension_id, object_category_id, object_scope_id, object_scope_dict)

    @controller.protected()
    def get_action_scopes(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        return self.admin_api.get_action_scopes_dict(user_id, intra_extension_id, action_category_id)

    @controller.protected()
    def add_action_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        action_scope_dict = dict()
        action_scope_dict['name'] = kw.get('action_scope_name', None)
        action_scope_dict['description'] = kw.get('action_scope_description', None)
        return self.admin_api.add_action_scope_dict(user_id, intra_extension_id, action_category_id, action_scope_dict)

    @controller.protected()
    def get_action_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        action_scope_id = kw.get('action_scope_id', None)
        return self.admin_api.get_action_scope_dict(user_id, intra_extension_id, action_category_id, action_scope_id)

    @controller.protected()
    def del_action_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        action_scope_id = kw.get('action_scope_id', None)
        self.admin_api.del_action_scope(user_id, intra_extension_id, action_category_id, action_scope_id)

    @controller.protected()
    def set_action_scope(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_category_id = kw.get('action_category_id', None)
        action_scope_id = kw.get('action_scope_id', None)
        action_scope_dict = dict()
        action_scope_dict['name'] = kw.get('action_scope_name', None)
        action_scope_dict['description'] = kw.get('action_scope_description', None)
        return self.admin_api.set_action_scope_dict(user_id, intra_extension_id, action_category_id, action_scope_id, action_scope_dict)

    # Assignment functions

    @controller.protected()
    def add_subject_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_id = kw.get('subject_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        subject_scope_id = kw.get('subject_scope_id', None)
        return self.admin_api.add_subject_assignment_list(user_id, intra_extension_id, subject_id, subject_category_id, subject_scope_id)

    @controller.protected()
    def get_subject_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_id = kw.get('subject_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        return self.admin_api.get_subject_assignment_list(user_id, intra_extension_id, subject_id, subject_category_id)

    @controller.protected()
    def del_subject_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        subject_id = kw.get('subject_id', None)
        subject_category_id = kw.get('subject_category_id', None)
        subject_scope_id = kw.get('subject_scope_id', None)
        self.admin_api.del_subject_assignment(user_id, intra_extension_id, subject_id, subject_category_id, subject_scope_id)

    @controller.protected()
    def add_object_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_id = kw.get('object_id', None)
        object_category_id = kw.get('object_category_id', None)
        object_scope_id = kw.get('object_scope_id', None)
        return self.admin_api.add_object_assignment_list(user_id, intra_extension_id, object_id, object_category_id, object_scope_id)

    @controller.protected()
    def get_object_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_id = kw.get('object_id', None)
        object_category_id = kw.get('object_category_id', None)
        return self.admin_api.get_object_assignment_list(user_id, intra_extension_id, object_id, object_category_id)

    @controller.protected()
    def del_object_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        object_id = kw.get('object_id', None)
        object_category_id = kw.get('object_category_id', None)
        object_scope_id = kw.get('object_scope_id', None)
        self.admin_api.del_object_assignment(user_id, intra_extension_id, object_id, object_category_id, object_scope_id)

    @controller.protected()
    def add_action_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_id = kw.get('action_id', None)
        action_category_id = kw.get('action_category_id', None)
        action_scope_id = kw.get('action_scope_id', None)
        return self.admin_api.add_action_assignment_list(user_id, intra_extension_id, action_id, action_category_id, action_scope_id)

    @controller.protected()
    def get_action_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_id = kw.get('action_id', None)
        action_category_id = kw.get('action_category_id', None)
        return self.admin_api.get_action_assignment_list(user_id, intra_extension_id, action_id, action_category_id)

    @controller.protected()
    def del_action_assignment(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        action_id = kw.get('action_id', None)
        action_category_id = kw.get('action_category_id', None)
        action_scope_id = kw.get('action_scope_id', None)
        self.admin_api.del_action_assignment(user_id, intra_extension_id, action_id, action_category_id, action_scope_id)

    # Metarule functions

    @controller.protected()
    def get_aggregation_algorithm(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_aggregation_algorithm_id(user_id, intra_extension_id)

    @controller.protected()
    def set_aggregation_algorithm(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        aggregation_algorithm_id = kw.get('aggregation_algorithm_id', None)
        return self.admin_api.set_aggregation_algorithm_id(user_id, intra_extension_id, aggregation_algorithm_id)

    @controller.protected()
    def get_sub_meta_rules(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        return self.admin_api.get_sub_meta_rules_dict(user_id, intra_extension_id)

    @controller.protected()
    def add_sub_meta_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_dict = dict()
        sub_meta_rule_dict['name'] = kw.get('sub_meta_rule_name', None)
        sub_meta_rule_dict['algorithm'] = kw.get('sub_meta_rule_algorithm', None)
        sub_meta_rule_dict['subject_categories'] = kw.get('sub_meta_rule_subject_categories', None)
        sub_meta_rule_dict['object_categories'] = kw.get('sub_meta_rule_object_categories', None)
        sub_meta_rule_dict['action_categories'] = kw.get('sub_meta_rule_action_categories', None)
        return self.admin_api.add_sub_meta_rule_dict(user_id, intra_extension_id, sub_meta_rule_dict)

    @controller.protected()
    def get_sub_meta_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        return self.admin_api.get_sub_meta_rule_dict(user_id, intra_extension_id, sub_meta_rule_id)

    @controller.protected()
    def del_sub_meta_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        self.admin_api.del_sub_meta_rule(user_id, intra_extension_id, sub_meta_rule_id)

    @controller.protected()
    def set_sub_meta_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        sub_meta_rule_dict = dict()
        sub_meta_rule_dict['name'] = kw.get('sub_meta_rule_name', None)
        sub_meta_rule_dict['algorithm'] = kw.get('sub_meta_rule_algorithm', None)
        sub_meta_rule_dict['subject_categories'] = kw.get('sub_meta_rule_subject_categories', None)
        sub_meta_rule_dict['object_categories'] = kw.get('sub_meta_rule_object_categories', None)
        sub_meta_rule_dict['action_categories'] = kw.get('sub_meta_rule_action_categories', None)
        return self.admin_api.set_sub_meta_rule_dict(user_id, intra_extension_id, sub_meta_rule_id, sub_meta_rule_dict)

    # Rules functions
    @controller.protected()
    def get_rules(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        return self.admin_api.get_rules_dict(user_id, intra_extension_id, sub_meta_rule_id)

    @controller.protected()
    def add_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        subject_category_list = kw.get('subject_categories', [])
        object_category_list = kw.get('object_categories', [])
        action_category_list = kw.get('action_categories', [])
        enabled_bool = kw.get('enabled', True)
        rule_list = subject_category_list + action_category_list + object_category_list + [enabled_bool, ]
        return self.admin_api.add_rule_dict(user_id, intra_extension_id, sub_meta_rule_id, rule_list)

    @controller.protected()
    def get_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        rule_id = kw.get('rule_id', None)
        return self.admin_api.get_rule_dict(user_id, intra_extension_id, sub_meta_rule_id, rule_id)

    @controller.protected()
    def del_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        rule_id = kw.get('rule_id', None)
        self.admin_api.del_rule(user_id, intra_extension_id, sub_meta_rule_id, rule_id)

    @controller.protected()
    def set_rule(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        intra_extension_id = kw.get('intra_extension_id', None)
        sub_meta_rule_id = kw.get('sub_meta_rule_id', None)
        rule_id = kw.get('rule_id', None)
        rule_list = list()
        subject_category_list = kw.get('subject_categories', [])
        object_category_list = kw.get('object_categories', [])
        action_category_list = kw.get('action_categories', [])
        rule_list = subject_category_list + action_category_list + object_category_list
        return self.admin_api.set_rule_dict(user_id, intra_extension_id, sub_meta_rule_id, rule_id, rule_list)


@dependency.requires('authz_api')
class InterExtensions(controller.V3Controller):

    def __init__(self):
        super(InterExtensions, self).__init__()

    def _get_user_from_token(self, token_id):
        response = self.token_provider_api.validate_token(token_id)
        token_ref = token_model.KeystoneToken(token_id=token_id, token_data=response)
        return token_ref['user']

    # @controller.protected()
    # def get_inter_extensions(self, context, **kw):
    #     user = self._get_user_from_token(context.get('token_id'))
    #     return {
    #         'inter_extensions':
    #             self.interextension_api.get_inter_extensions()
    #     }

    # @controller.protected()
    # def get_inter_extension(self, context, **kw):
    #     user = self._get_user_from_token(context.get('token_id'))
    #     return {
    #         'inter_extensions':
    #             self.interextension_api.get_inter_extension(uuid=kw['inter_extension_id'])
    #     }

    # @controller.protected()
    # def create_inter_extension(self, context, **kw):
    #     user = self._get_user_from_token(context.get('token_id'))
    #     return self.interextension_api.create_inter_extension(kw)

    # @controller.protected()
    # def delete_inter_extension(self, context, **kw):
    #     user = self._get_user_from_token(context.get('token_id'))
    #     if 'inter_extension_id' not in kw:
    #         raise exception.Error
    #     return self.interextension_api.delete_inter_extension(kw['inter_extension_id'])


@dependency.requires('moonlog_api', 'authz_api')
class Logs(controller.V3Controller):

    def __init__(self):
        super(Logs, self).__init__()

    def _get_user_id_from_token(self, token_id):
        response = self.token_provider_api.validate_token(token_id)
        token_ref = token_model.KeystoneToken(token_id=token_id, token_data=response)
        return token_ref['user']

    @controller.protected()
    def get_logs(self, context, **kw):
        user_id = self._get_user_id_from_token(context.get('token_id'))
        options = kw.get('options', '')
        return self.moonlog_api.get_logs(user_id, options)


@dependency.requires('identity_api', "token_provider_api", "resource_api")
class MoonAuth(controller.V3Controller):

    def __init__(self):
        super(MoonAuth, self).__init__()

    def _get_project(self, uuid="", name=""):
        projects = self.resource_api.list_projects()
        for project in projects:
            if uuid and uuid == project['id']:
                return project
            elif name and name == project['name']:
                return project

    def get_token(self, context, **kw):
        data_auth = {
            "auth": {
                "identity": {
                    "methods": [
                        "password"
                    ],
                    "password": {
                        "user": {
                            "domain": {
                                "id": "Default"
                            },
                            "name": kw['username'],
                            "password": kw['password']
                        }
                    }
                }
            }
        }

        message = {}
        if "project" in kw:
            project = self._get_project(name=kw['project'])
            if project:
                data_auth["auth"]["scope"] = dict()
                data_auth["auth"]["scope"]['project'] = dict()
                data_auth["auth"]["scope"]['project']['id'] = project['id']
            else:
                message = {
                    "error": {
                        "message": "Unable to find project {}".format(kw['project']),
                        "code": 200,
                        "title": "UnScopedToken"
                    }}

#        req = requests.post("http://localhost:5000/v3/auth/tokens",
#                            json=data_auth,
#                            headers={"Content-Type": "application/json"}
#                            )
        req = requests.post("http://172.16.1.222:5000/v3/auth/tokens",
                            json=data_auth,
                            headers={"Content-Type": "application/json"}
                            )
        if req.status_code not in (200, 201):
            LOG.error(req.text)
        else:
            _token = req.headers['X-Subject-Token']
            _data = req.json()
            _result = {
                "token": _token,
                'message': message
            }
            try:
                _result["roles"] = map(lambda x: x['name'], _data["token"]["roles"])
            except KeyError:
                pass
            return _result
        return {"token": None, 'message': req.json()}

