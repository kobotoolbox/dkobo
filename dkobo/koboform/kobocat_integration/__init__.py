from rest_framework.test import APIClient
from rest_framework.authtoken.models import Token
import requests

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
