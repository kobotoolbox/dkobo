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
from dkobo.koboform.xlform import Xlform

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
    out_array = []
    survey = imported_sheets.get("survey", [])
    choices = imported_sheets.get("choices", [])
    count = settings.KOBO_SURVEY_IMPORT_COUNT
    if count is -1:
        survey_rows = survey
    else:
        survey_rows = survey[0:count]

    for row in survey_rows:
        if len(row.keys()) == 0:
            continue
        name = row.get("name")
        survey_dict = {'survey': [row]}

        if len(choices) > 0:
            survey_dict['choices'] = choices

        out_array.append(
            (name, _dict_to_csv(survey_dict),)
            )
    return out_array

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
            sys.exit(1)
        print user.survey_drafts.count()
        user.survey_drafts.filter().delete()
        # csvs = _convert_xls_file_to_individual_surveys(filename)
        for (name, csvstr) in _convert_xls_file_to_individual_surveys(filename):
            SurveyDraft.objects.create(user=user, name=name, body=Xlform(csvstr)._shrunk, asset_type="question")
        print user.survey_drafts.count()
