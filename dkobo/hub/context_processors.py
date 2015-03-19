from dkobo.hub.models import SitewideMessage
from django.contrib.sites.models import Site
from django.conf import settings
from dkobo.koboform import kobocat_integration

def welcome_message(request):
    if request.path == '/accounts/register/':
        ctx = {}
        try:
            w_message = SitewideMessage.objects.get(slug='welcome_message')
            ctx['welcome_message'] = w_message.body
        except SitewideMessage.DoesNotExist, e:
            pass

        if settings.KOBOCAT_URL:
            ctx['kobocat_url'] = settings.KOBOCAT_URL
        else:
            ctx['kobocat_url'] = None
        return ctx
    else:
        return {}

def external_service_tokens(request):
    context = {}
    if settings.TRACKJS_TOKEN:
        context['trackjs_token'] = settings.TRACKJS_TOKEN
    if settings.GOOGLE_ANALYTICS_TOKEN:
        context['google_analytics_token'] = settings.GOOGLE_ANALYTICS_TOKEN
    if settings.LIVE_RELOAD:
        context['livereload_address'] = "http://%s:35729/livereload.js" % request.META['HTTP_HOST'].split(':')[0]
    context['DEBUG'] = settings.DEBUG
    return context
