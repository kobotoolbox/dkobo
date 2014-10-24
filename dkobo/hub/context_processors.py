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
