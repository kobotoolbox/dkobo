from django.db import models
from django.contrib.auth.models import User
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

    @property
    def _pyxform_survey(self):
        import pyxform_utils
        survey = pyxform_utils.create_survey_from_csv_text(self.body)
        survey.title = self.name
        return survey

    @property
    def id_string(self):
        # Ideally, we could determine this without needing to load the entire
        # survey into pyxform, but parsing csvs from unk sources can be complicated
        # and this method of finding the id_string is (at least) consistent.
        return self._pyxform_survey.id_string

    def to_xml(self):
        return self._pyxform_survey.to_xml()

    def to_xls(self):
        import pyxform_utils
        return pyxform_utils.convert_csv_to_xls(self.body)

class SurveyPreview(models.Model):
    unique_string = models.CharField(max_length=64, null=False, unique=True)
    csv = models.TextField()
    xml = models.TextField()
    date_created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def _generate_unique_string(kls, csv):
        return md5.new(u'csv=%s' % csv.encode("utf-8")).hexdigest()

    @classmethod
    def _get_or_create(kls, *args, **kwargs):
        csv = kwargs.get('csv')
        kwargs[u'unique_string'] = kls._generate_unique_string(csv)
        try:
            return kls.objects.get(unique_string=kwargs[u'unique_string'])
        except kls.DoesNotExist, e:
            new_preview = kls(**kwargs)
            new_preview.save()
            return new_preview

    def save(self, *args, **kwargs):
        if self.unique_string in [u'', None]:
            self.unique_string = SurveyPreview._generate_unique_string(self.csv)
        if self.xml in [u'', None]:
            import pyxform_utils
            self.xml = pyxform_utils.create_survey_from_csv_text(self.csv, default_name="SurveyPreview__save").to_xml()
        super(SurveyPreview, self).save(*args, **kwargs)
