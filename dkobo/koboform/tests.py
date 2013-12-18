from django.test import TestCase
from lxml import etree
from django.contrib.auth.models import User
from django.test.client import Client
from dkobo.koboform.models import SurveyDraft
import utils

text = """"survey",,,,,
                ,"name","type","label","hint","required"
                ,"gps","geopoint","Record your current location",,"false"
                ,"start","start",,,
                ,"end","end",,,
                "settings",
                ,"form_title"
                ,"New survey" """

class CreateSurveyFromCsvTextTests(TestCase):
    def test_parses_survey_passed_in_as_csv_and_returns_xml_representation(self):
        xml = utils.create_survey_from_csv_text(text).to_xml()
        etree.fromstring(xml)

class Views_CsvToXformTests(TestCase):
    def test_parses_passed_csv_data(self):
        response = self.client.post('/csv', {'txtImport': text})
        etree.fromstring(response.content)


class SaveSurveyDrafts(TestCase):
    def setUp(self):
        if User.objects.count() is 0:
            new_user = User(username="user1", email="user1@example.com")
            new_user.set_password("pass")
            new_user.save()
        self.user = User.objects.all()[0]

    def test_user_can_create_and_access_survey_draft(self):
        '''
        When creating a survey draft, this tests that
         * the database count increments
         * the survey shows up on the list of survey-drafts for the logged in user
         * the new survey-draft is queryable
        '''
        sdcount = SurveyDraft.objects.count()
        self.assertEqual(sdcount, 0)
        sdname = "testing survey draft"
        SurveyDraft.objects.create(name=sdname, body=text, user=self.user)
        self.assertEqual(SurveyDraft.objects.count(), sdcount + 1)
        survey = SurveyDraft.objects.all()[0]
        self.assertEqual(survey.name, sdname)
