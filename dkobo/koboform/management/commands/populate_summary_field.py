from django.core.management.base import BaseCommand, CommandError
from dkobo.koboform.models import SurveyDraft
import time

class Command(BaseCommand):
    def handle(self, *args, **options):
        for draft in SurveyDraft.objects.all().order_by('date_modified'):
            draft.save()
            time.sleep(1)