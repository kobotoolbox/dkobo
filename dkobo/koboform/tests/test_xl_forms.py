#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.test import TestCase
from lxml import etree
from StringIO import StringIO
from django.contrib.auth.models import User
# from django.test.client import Client
# from pyxform import xls2json_backends
# from dkobo.koboform.models import SurveyDraft, SurveyPreview
# from dkobo.koboform import pyxform_utils
# from dkobo.koboform import utils
import json


example_unshrunk = """"survey",,,,,
                ,"name","type","label","hint","required"
                ,"s1","select_one list_a","Select one",,"false"
                "choices",,,,
                ,"name","label",,
                ,"list_a","blah"
                ,"list_a","blah2"
                ,"list_b","blah3"
                ,"list_c","blah4"\
"""

example_shrunk = """"survey",,,,,
                ,"name","type","label","hint","required"
                ,"s1","select_one list_a","Select one",,"false"
                "choices",,,,
                ,"name","label",,
                ,"list_a","blah"
                ,"list_a","blah2"\
"""


from dkobo.koboform.xlform import Xlform

class CreatesXlform(TestCase):
    def test_creates_and_shrinks(self):
        unshrunk_xlform = Xlform(example_unshrunk) 
        self.assertEqual(unshrunk_xlform._csv, example_unshrunk)
        self.assertEqual(len(unshrunk_xlform._rows), 9)
        self.assertEqual(unshrunk_xlform._first_list_name, "list_a")
        shrunk_csv = unshrunk_xlform._shrunk
        self.assertEqual(shrunk_csv, example_shrunk)
        # def _analyze(csv_str):
        #     rowCount = len(csv_str.split("\n"))
        #     obj = {'rows': rowCount}
        #     return obj
        # self.assertEqual(_analyze(shrunk_csv), _analyze(example_shrunk))
