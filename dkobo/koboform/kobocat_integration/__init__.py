from django.conf import settings

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
