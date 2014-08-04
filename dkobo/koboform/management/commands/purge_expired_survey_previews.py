from django.core.management.base import BaseCommand, CommandError
from dkobo.koboform.models import SurveyPreview
from django.conf import settings
import datetime

class Command(BaseCommand):

    def handle(self, *args, **options):
        exp_hours = settings.KOBO_SURVEY_PREVIEW_EXPIRATION
        time_ago = datetime.datetime.now() - datetime.timedelta(hours=exp_hours)
        expired_survey_previews = SurveyPreview.objects.filter(date_created__lt=time_ago)
        num_surveys = expired_survey_previews.count()
        print "Deleting %d surveys older than %d hours" % (num_surveys, exp_hours)
        expired_survey_previews.delete()
