from dkobo.hub.models import SitewideMessage
from django.contrib.sites.models import Site
import re
from django.conf import settings
from dkobo.koboform import kobocat_integration

def welcome_message(request):
    print """
    please update dkobo settings.py to use 'dkobo.hub.context_processors.site_messages'
    instead of 'dkobo.hub.context_processors.welcome_message'
    """
    return site_messages(request)

def _unwrap_paragraph(msg):
    """
    markdown wraps all text in paragraphs.
    this is great, but not always what we want.
    this provides a way to 
    """
    matches = re.match(r'^<div nowrap>(.*)</div>$', msg)
    if matches:
        try:
            return matches.groups()[0]
        except KeyError:
            return msg
    return msg

def site_messages(request):
    ctx = {}
    site_messages = [
            'logo', # in the top bar. displayed in index.html
            'head', # css
            'footer', # in the footer bar
            ]

    if request.path == '/accounts/register/':
        site_messages.append('welcome_message')

    messages = SitewideMessage.objects.filter(slug__in=site_messages)

    for message in messages:
        template_accessible_slug = "sitewide__%s" % message.slug
        ctx[template_accessible_slug] = _unwrap_paragraph(message.body)

    if settings.KOBOCAT_URL:
        ctx['kobocat_url'] = settings.KOBOCAT_URL
    return ctx

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
