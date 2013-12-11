from django.test import TestCase
from django.core.urlresolvers import reverse
from lxml import etree

import pyxform

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