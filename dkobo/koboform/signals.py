from django.conf import settings
from django.contrib.auth.models import User, Permission
from django.db.models.signals import post_save

def set_model_level_permissions(sender, instance, created, raw, **kwargs):
    ''' Mirror KoBoCAT's set_api_permissions_for_user() and KPI's
    grant_default_model_level_perms(); see
    https://github.com/kobotoolbox/kobocat/blob/master/onadata/libs/utils/user_auth.py
    and https://github.com/kobotoolbox/kpi/blob/master/kpi/model_utils.py '''
    if raw or not created:
        # Only apply permissions at creation; we aren't allowed to touch raw
        # saves
        return
    for app_label, model in settings.EXTERNAL_DEFAULT_PERMISSION_CONTENT_TYPES:
        for permission in Permission.objects.filter(
                content_type__app_label=app_label,
                content_type__model=model):
            # We open the model-level permissions wide, allowing object-level
            # permissions to serve as the real gatekeepers
            instance.user_permissions.add(permission)

post_save.connect(set_model_level_permissions, sender=User)
