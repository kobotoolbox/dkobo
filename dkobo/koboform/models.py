from django.db import models
from django.contrib.auth.models import User
from pyxform_utils import create_survey_from_csv_text
import md5

class SurveyDraft(models.Model):
    '''
    SurveyDrafts belong to a user and contain the minimal representation of
    the draft survey of the user and of the question library.
    '''
    user = models.ForeignKey(User, related_name="survey_drafts")
    name = models.CharField(max_length=255, null=False)
    body = models.TextField()
    description = models.CharField(max_length=255, null=True)
    date_created = models.DateTimeField(auto_now_add=True)
    date_modified = models.DateTimeField(auto_now=True)
    in_question_library = models.BooleanField(default=False)

class SurveyPreview(models.Model):
    unique_string = models.CharField(max_length=64, null=False, unique=True)
    csv = models.TextField()
    xml = models.TextField()
    date_created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def _generate_unique_string(kls, csv):
        return md5.new("csv=%s" % (user.id, csv)).hexdigest()

    def save(self, *args, **kwargs):
        self.unique_string = SurveyPreview._generate_unique_string(self.csv)
        self.xml = create_survey_from_csv_text(self.csv, default_name="SurveyPreview__save").to_xml()
        super(SurveyPreview, self).save(*args, **kwargs)
