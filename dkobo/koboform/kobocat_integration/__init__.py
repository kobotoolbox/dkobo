import requests

from django.conf import settings

from rest_framework.test import APIClient
from rest_framework.authtoken.models import Token

def publish_survey_draft(survey_draft, kobocat_internal_url):
    url, data, headers = _publish_survey_draft_params(survey_draft, kobocat_internal_url)
    resp = requests.post(url, data=data, headers=headers)
    resp_json = resp.json()
    status_code = resp.status_code
    return (status_code, resp_json)

def _publish_survey_draft_params(survey_draft, kobocat_internal_url):
    url = "%s/api/v1/forms" % (kobocat_internal_url)
    params = {u'text_xls_form': survey_draft.body}
    _tok = _get_token_for_user(survey_draft.user)
    headers = {u'Authorization': 'Token %s' % _tok}
    return (url, params, headers)

def _get_token_for_user(user):
    (token, is_new) = Token.objects.get_or_create(user=user)
    return token.key

def _is_enabled():
    return hasattr(settings, 'KOBOCAT_URL') and settings.KOBOCAT_URL

def _kobocat_url(path="/", query_string=False, internal=False):
    if internal:
        prepped_url = settings.KOBOCAT_INTERNAL_URL
    else:
        prepped_url = settings.KOBOCAT_URL

    if prepped_url == None:
        prepped_url = "/kobocat"

    prepped_url += path

    if query_string:
        prepped_url += '?%s' % query_string

    return prepped_url
