#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.test import TestCase
from lxml import etree
from StringIO import StringIO
from django.contrib.auth.models import User
from django.test.client import Client
from pyxform import xls2json_backends
from dkobo.koboform.models import SurveyDraft, SurveyPreview
from dkobo.koboform import pyxform_utils
from dkobo.koboform import utils
import json
import os


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

class ConvertXlsToCsvTests(TestCase):
    def test_converts_sheeted_xls(self):
        base_dir = os.path.join("dkobo", "koboform", "tests", "example_xls")
        with_accents = os.path.join(base_dir, "with_accents.xls")
        with_accents_csv = os.path.join(base_dir, "with_accents.csv")
        without_accents = os.path.join(base_dir, "without_accents.xls")
        without_accents_csv = os.path.join(base_dir, "without_accents.csv")
        with open(without_accents_csv, 'r') as ff:
            expected = ff.read()
        with open(without_accents, 'rb') as fff:
            out_csv = pyxform_utils.convert_xls_to_csv_string(fff)
            self.assertEqual(expected, out_csv)
        with open(with_accents_csv, 'rb') as ff:
            expected = ff.read()
        with open(with_accents, 'rb') as fff:
            out_csv = pyxform_utils.convert_xls_to_csv_string(fff)
            self.assertEqual(expected, out_csv)

class Views_CsvToXformTests(TestCase):
    def test_parses_passed_csv_data(self):
        response = self.client.post('/csv', {'txtImport': text})
        etree.fromstring(response.content)

simple_yn = """survey,,,
,name,label,type
,hithere,"Hi there",text
,s1,"Select one","select_one yn"
choices,,,
,"list name",name,label
,yn,y,Yes
,yn,n,No
"""

sample_for_ordered_columns = """"survey",,,,,,,,
,"name","type","label","hint","required"
,"ug3fj23","text","What's your name?",,"false",
,"ii3we34","select_multiple hv1rw91","Choose from my options",,"false"
"choices",,,
,"list name","name","label"
,"hv1rw91","my_option","My option"
,"hv1rw91","my_option_2","My Option 2"
"settings",,
,"form_title","form_id"
,"What is your name","new_survey"
"""

utf_survey = u"""\
"survey",,,
,"name","type","label"
,"burger_toppings","text","What toppings do you prefer on your 🍔s?"
"""

class CreateWorkbookFromCsvTests(TestCase):
    def test_xls_to_dict(self):
        # convert a CSV to XLS using our new method
        new_xls = pyxform_utils.convert_csv_to_xls(simple_yn)

        # convert our new XLS to dict (using pyxform)
        xls_dict = xls2json_backends.xls_to_dict(new_xls)
        # convert the original CSV to dict (using pyxform)
        csv_dict = xls2json_backends.csv_to_dict(StringIO(simple_yn))
        # Our function, "pyxform_utils.csv_to_xls" performs (CSV -> XLS)
        # This assertion tests equivalence of
        #   (CSV) -> dict_representation
        #   (CSV -> XLS) -> dict_representation
        self.assertEqual(csv_dict, xls_dict)

    def test_order_of_dict_values(self):
        csv_dict = xls2json_backends.csv_to_dict(StringIO(sample_for_ordered_columns))
        self.assertEqual(csv_dict.keys()[0], "survey")
        survey = csv_dict.get("survey")
        self.assertEqual(survey[0].keys(), ["name", "type", "label", "required"])

    def test_unicode_surveys_work(self):
        survey = utils.create_survey_from_csv_text(utf_survey)
        xml = survey.to_xml()
        self.assertTrue(u"🍔" in xml)

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

class SurveyPreviews(TestCase):
    def setUp(self):
        self.client = Client()

    def test_can_generate_preview(self):
        self.assertEqual(SurveyPreview.objects.count(), 0)
        response = self.client.post("/koboform/survey_preview",
                json.dumps({u'body': utf_survey}),
                content_type="application/json")
        response_obj = json.loads(response.content)
        self.assertEqual(response_obj.get(u'error', None), None)
        self.assertEqual(SurveyPreview.objects.count(), 1)