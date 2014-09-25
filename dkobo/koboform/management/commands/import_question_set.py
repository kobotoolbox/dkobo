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

def _dict_to_csv(imported_sheets):
    foo = StringIO.StringIO()
    writer = csv.writer(
        foo, quotechar='"', doublequote=True, escapechar='\\', delimiter=',', quoting=csv.QUOTE_ALL)
    for sheet_name, rows in imported_sheets.items():
        writer.writerow([sheet_name])
        out_keys = []
        out_rows = []
        for row in rows:
            out_row = []
            for key in row.keys():
                if key not in out_keys:
                    out_keys.append(key.encode("UTF-8"))
            for out_key in out_keys:
                out_row.append(row.get(out_key, "").encode("UTF-8"))
            out_rows.append(out_row)
        writer.writerow([None] + out_keys)
        for out_row in out_rows:
            writer.writerow([None] + out_row)
    return foo.getvalue()

def _convert_xls_file_to_individual_surveys(filename):
    imported_sheets = pyxform.xls2json_backends.xls_to_dict(filename)
    imported_sheets_as_csv = _dict_to_csv(imported_sheets)
    return xlform.split_apart_survey(imported_sheets_as_csv)

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
        csv_files = _convert_xls_file_to_individual_surveys(filename)
        print "xls has been split apart, now entering them into the db"
        for csvstr in csv_files:
            SurveyDraft.objects.create(user=user, name="imported_question", body=csvstr, asset_type="question")
        print "Count [after import]:  %d" % user.survey_drafts.count()
