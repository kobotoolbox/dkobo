from dkobo.main.models import SitewideMessages
from django.contrib.sites.models import get_current_site

def welcome_message(request):
    if request.path == '/accounts/register/':
        try:
            w_message = SitewideMessages.objects.get(slug='welcome_message')
            return {'welcome_message': w_message.body, 'site_domain': get_current_site(request).domain}
        except SitewideMessages.DoesNotExist, e:
            pass
    return {}