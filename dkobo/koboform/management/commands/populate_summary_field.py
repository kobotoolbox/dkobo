from django.core.management.base import BaseCommand, CommandError
from dkobo.koboform.models import SurveyDraft

def _populate_summary_field(surveydraft_model=SurveyDraft):
    ''' When running from a migration, surveydraft_model must be set to the
    frozen SurveyDraft model, e.g. `orm.SurveyDraft` '''
    date_modified_field = filter(
        lambda f: f.name == "date_modified", surveydraft_model._meta.fields)[0]
    date_modified_field.auto_now = False
    for draft in surveydraft_model.objects.all().order_by('date_modified'):
        draft.save()
    # for peace of mind--
    date_modified_field.auto_now = True

class Command(BaseCommand):
    def handle(self, *args, **options):
        print "Updating summary field for %s SurveyDrafts" % SurveyDraft.objects.count()
        _populate_summary_field()
