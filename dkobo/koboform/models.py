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

    def generate_preview(self):
        try:
            unique_string = SurveyPreview._generate_unique_string(self.user, self.body)
            return SurveyPreview.objects.get(unique_string=unique_string)
        except SurveyPreview.DoesNotExist, e:
            return SurveyPreview.objects.create(survey_draft=self)


class SurveyPreview(models.Model):
    unique_string = models.CharField(max_length=64, null=False, unique=True)
    survey_draft = models.ForeignKey(SurveyDraft, null=False, related_name="previews")
    csv = models.TextField()
    xml = models.TextField()
    date_created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def _generate_unique_string(kls, user, csv):
        return md5.new("user=%d&csv=%s" % (user.id, csv)).hexdigest()

    def save(self, *args, **kwargs):
        sd = self.survey_draft
        self.unique_string = super(self)._generate_unique_string(sd.user, sd.body)
        self.csv = sd.body
        self.xml = create_survey_from_csv_text(sd.body, default_name=sd.name).to_xml()
        super(SurveyPreview, self).save(*args, **kwargs)
