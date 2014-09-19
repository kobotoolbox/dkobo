from dkobo.main.models import SitewideMessages
from django.contrib.sites.models import Site
from django.conf import settings

def welcome_message(request):
    if request.path == '/accounts/register/':
        try:
            w_message = SitewideMessages.objects.get(slug='welcome_message')
            domain = Site.objects.get(id=settings.SITE_ID).domain
            return {'welcome_message': w_message.body, 'site_domain': domain}
        except SitewideMessages.DoesNotExist, e:
            pass
    return {}