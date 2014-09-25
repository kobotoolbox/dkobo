#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.test import TestCase
import re


example_unshrunk = """"survey",,,,,
                ,"name","type","label","hint","required"
                ,"s1","select_one list_a","Select one",,"false"
                "choices",,,,
                ,"list name","label",,
                ,"list_a","blah"
                ,"list_a","blah2"
                ,"list_b","blah3"
                ,"list_c","blah4"\
                """

example_3q = """"survey",,,,,
                ,"name","type","label","hint","required"
                ,"q1","text","Question1",,"false"
                ,"q2","text","Question2",,"false"
                ,"q3","text","Question3",,"false"\
                """

def _stripped(scsv):
    return '\n'.join([line.strip() for line in scsv.split('\n')])

from dkobo.koboform import xlform

class ShrinksXlform(TestCase):
    def test_creates_and_shrinks(self):
        full = example_unshrunk
        shrunk = xlform.shrink_survey(_stripped(example_unshrunk))
        self.assertTrue(bool(re.search('list_b', full)))
        self.assertTrue(not re.search('list_b', shrunk))

    def test_split_into_individual_surveys(self):
        split_surveys = xlform.split_apart_survey(_stripped(example_3q))
        self.assertEqual(len(split_surveys), 3)
