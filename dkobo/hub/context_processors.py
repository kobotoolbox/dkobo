from dkobo.hub.models import SitewideMessage
from django.contrib.sites.models import Site
from django.conf import settings
from dkobo.koboform import kobocat_integration

def welcome_message(request):
    messages = {}
    for msg in SitewideMessage.objects.all():
        messages[msg.slug] = msg.body
    return messages

def external_service_tokens(request):
    context = {}
    if settings.KOBOCAT_URL:
        context['kobocat_url'] = settings.KOBOCAT_URL
    else:
        context['kobocat_url'] = None
    if settings.TRACKJS_TOKEN:
        context['trackjs_token'] = settings.TRACKJS_TOKEN
    if settings.BETA_TOGGLE_URL:
        context['beta_toggle_url'] = settings.BETA_TOGGLE_URL
    if settings.GOOGLE_ANALYTICS_TOKEN:
        context['google_analytics_token'] = settings.GOOGLE_ANALYTICS_TOKEN
    if settings.LIVE_RELOAD:
        context['livereload_address'] = "http://%s:35729/livereload.js" % request.META['HTTP_HOST'].split(':')[0]
    context['DEBUG'] = settings.DEBUG
    return context
