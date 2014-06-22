import requests

from django.conf import settings

from rest_framework.test import APIClient
from rest_framework.authtoken.models import Token

def publish_survey_draft(survey_draft, kobocat_server):
    url, data, headers = _publish_survey_draft_params(survey_draft, kobocat_server)
    resp = requests.post(url, data=data, headers=headers)
    resp_json = resp.json()
    status_code = resp.status_code
    return (status_code, resp_json)

def _publish_survey_draft_params(survey_draft, kobocat_server):
    url = "%s/api/v1/forms" % (kobocat_server)
    params = {u'text_xls_form': survey_draft.body}
    _tok = _get_token_for_user(survey_draft.user)
    headers = {u'Authorization': 'Token %s' % _tok}
    return (url, params, headers)

def _get_token_for_user(user):
    (token, is_new) = Token.objects.get_or_create(user=user)
    return token.key

def _kobocat_url(path="/", query_string=False, append_origin_key=False):
    protocol = settings.KOBOCAT_SERVER_PROTOCOL
    server = settings.KOBOCAT_SERVER
    if settings.KOBOCAT_SERVER_PORT and str(settings.KOBOCAT_SERVER_PORT) != '80':
        server += ':%s' % (settings.KOBOCAT_SERVER_PORT)
    query_string = []
    if query_string:
        query_string.append(query_string)
    if len(query_string) > 0:
        path += "?%s" % ('&'.join(query_string))
    return '%s://%s%s' % (protocol, server, path)
