from django.test import TestCase
from lxml import etree

import pyxform

import utils

class CreateSurveyFromCsvTextTests(TestCase):
    
    def test_parses_survey_passed_in_as_csv_and_returns_xml_representation(self):
        text = """"survey",,,,,
                ,"name","type","label","hint","required"
                ,"gps","geopoint","Record your current location",,"false"
                ,"start","start",,,
                ,"end","end",,,
                "settings",
                ,"form_title"
                ,"New survey" """

        xml = utils.create_survey_from_csv_text(text).to_xml()
        
        etree.fromstring(xml)