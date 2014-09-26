from django.core.management.base import BaseCommand, CommandError
from dkobo.koboform.models import SurveyDraft
from django.contrib.auth.models import User
from django.conf import settings
import StringIO
import tempfile
import pyxform
import urllib
import csv
import sys
import re
from dkobo.koboform import xlform
from dkobo.koboform import pyxform_utils

class Command(BaseCommand):
    def handle(self, *args, **options):
        username = args[0]
        filename = args[1]
        if re.match(r'^https?:', filename):
            tmp = tempfile.NamedTemporaryFile(suffix="xls")
            tmp.write(urllib.request.urlopen(filename).read())
            filename = tmp.name
        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist, e:
            print "User '%s' does not exist" % username
            sys.exit(1)
        print "Count [before import]: %d" % user.survey_drafts.count()
        user.survey_drafts.filter(asset_type="question").delete()
        
        with open(filename, 'rb') as ff:
            imported_sheets_as_csv = pyxform_utils.convert_xls_to_csv_string(ff)
        csv_files = xlform.split_apart_survey(imported_sheets_as_csv)

        print "xls has been split apart, now entering them into the db"
        for csvstr in csv_files:
            SurveyDraft.objects.create(user=user, name="imported_question", body=csvstr, asset_type="question")
        print "Count [after import]:  %d" % user.survey_drafts.count()
