import md5
import json

import pyxform_utils
from django.db import models
from django.contrib.auth.models import User
from jsonfield import JSONField
from taggit.managers import TaggableManager
import reversion

@reversion.register
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
    summary = JSONField()
    asset_type = models.CharField(max_length=32, null=True)
    tags = TaggableManager()


    @property
    def _pyxform_survey(self):
        import pyxform_utils
        valid_csv_body = pyxform_utils.convert_csv_to_valid_xlsform_unicode_csv(self.body)
        survey = pyxform_utils.create_survey_from_csv_text(valid_csv_body)
        survey.title = self.name
        return survey

    @property
    def id_string(self):
        # Ideally, we could determine this without needing to load the entire
        # survey into pyxform, but parsing csvs from unk sources can be complicated
        # and this method of finding the id_string is (at least) consistent.
        return self._pyxform_survey.id_string

    def _set_form_id_string(self, form_id_string, title=False):
        '''
        goal: rewrite this to avoid csv manipulation
        '''
        body = self.body.split('\n')

        form_settings=body.pop()

        if form_settings is u'':
            form_settings = body.pop() + '\n'
        form_settings_list = form_settings.split(',')

        if title and title != '':
            form_settings_list.pop(1)
            form_settings_list.insert(1, '"' + title + '"')
        if form_id_string and form_id_string != '':
            form_settings_list.pop(2)
            form_settings_list.insert(2, '"' + form_id_string + '"')

        body.append(','.join(form_settings_list))
        self.body = '\n'.join(body)

    def to_xml(self):
        return self._pyxform_survey.to_xml()

    def to_xls(self):
        import pyxform_utils
        return pyxform_utils.convert_csv_to_xls(self.body)

    def _summarize(self):
        try:
            self.summary = pyxform_utils.summarize_survey(self.body, self.asset_type)
        except Exception, err:
            self.summary = {'error': str(err)}

    def save(self, *args, **kwargs):
        self._summarize()
        super(SurveyDraft, self).save(*args, **kwargs)

class SurveyPreview(models.Model):
    unique_string = models.CharField(max_length=64, null=False, unique=True)
    csv = models.TextField()
    xml = models.TextField()
    date_created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def _generate_unique_string(kls, csv):
        return md5.new('csv=%s' % csv.encode("utf-8")).hexdigest()

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

        pyxform_survey = pyxform_utils.create_survey_from_csv_text(self.csv, default_name="SurveyPreview__save")

        if self.xml in [u'', None]:
            self.xml = pyxform_survey.to_xml()

        super(SurveyPreview, self).save(*args, **kwargs)
