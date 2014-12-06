from django.core.management.base import BaseCommand, CommandError
from dkobo.koboform.models import SurveyDraft

class Command(BaseCommand):
    def handle(self, *args, **options):
        print "Updating summary field for %s SurveyDrafts" % SurveyDraft.objects.count()

        date_modified_field = filter(lambda f: f.name == "date_modified", SurveyDraft._meta.fields)[0]
        date_modified_field.auto_now = False
        for draft in SurveyDraft.objects.all().order_by('date_modified'):
            draft.save()
        # for peace of mind--
        date_modified_field.auto_now = True
