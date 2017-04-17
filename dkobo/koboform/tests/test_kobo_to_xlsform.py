#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.test import TestCase
from dkobo.koboform.kobo_to_xlsform import convert_any_kobo_features_to_xlsform_survey_structure
from dkobo.koboform.kobo_to_xlsform import _sluggify_valid_xml

def convert_survey(surv, choices=[], sheets={}):
    sheets.update({
        'survey': surv
        })
    if len(choices) > 0:
        sheets.update({
            'choices': choices
        })
    return convert_any_kobo_features_to_xlsform_survey_structure(sheets)

COLS = {
    'rank-cmessage': 'kobo--rank-constraint-message',
    'rank-items': 'kobo--rank-items',
    'score-choices': 'kobo--score-choices',
}

rank_s = [
    {
        'type': 'begin rank',
        'name': 'x',
        COLS['rank-cmessage']: 'Rank Message',
        COLS['rank-items']: 'items',
        'relevant': 'abcdef',
    },
    {'type': 'rank__level', 'name': 'rl1'},
    {'type': 'rank__level', 'name': 'rl2', 'appearance': 'overridden'},
    {'type': 'end rank'},
]

score_s = [
    {
        'type': 'begin score',
        'name': 'x',
        COLS['score-choices']: 'items',
        'relevant': 'ghijkl',
    },
    {'type': 'score__row', 'name': 'rl1'},
    {'type': 'score__row', 'name': 'rl2', 'appearance': 'overridden'},
    {'type': 'end score'},
]

items = [
    {'list name': 'items', 'name': 'a', 'label': 'A a a'},
    {'list name': 'items', 'name': 'b', 'label': 'B b b'},
    {'list name': 'items', 'name': 'c', 'label': 'C c c'},
]

class K2XSubModules(TestCase):
    def test_sluggify_valid_xml(self):
        '''
        corresponding to tests from the cs model.utils -> sluggifyLabel
        '''
        self.cases = [
            [["asdf jkl"],              "asdf_jkl"],
            [["2. asdf"],               "_2_asdf"],
            [[" hello "],               "hello"],
            [["asdf#123"],              "asdf_123"],
            # [["asdf", ["asdf"]],        "asdf_001"],
            # [["2. asdf", ["_2_asdf"]],  "_2_asdf_001"],
        ]
        for case in self.cases:
            [inp, expected] = case
            self.assertEqual(_sluggify_valid_xml(inp[0]), expected)

    # def test_increment(self):
    #     self.cases = [
    #         [["asdf", ["asdf"]],        "asdf_001"],
    #         [["2. asdf", ["_2_asdf"]],  "_2_asdf_001"],
    #     ]
    #     for case in self.cases:
    #         [inp, expected] = case
    #         self.assertEqual(_sluggify_valid_xml(inp[0], names=inp[1]), expected)

class Converter(TestCase):
    def test_rank_conversion(self):
        result = convert_survey(rank_s, items)
        surv = result['survey']
        self.assertEqual(len(surv), 5)
        self.assertEqual(surv[0]['appearance'], 'field-list')
        self.assertEqual(surv[0]['type'], 'begin group')
        self.assertEqual(surv[0]['relevant'], 'abcdef')

        self.assertEqual(surv[1]['type'], 'note')
        self.assertEqual(surv[1].get('relevant', None), None)

        self.assertEqual(surv[2]['required'], 'true')
        self.assertEqual(surv[2]['type'], 'select_one items')
        self.assertTrue('constraint' not in surv[2].keys())
        self.assertEqual(surv[2].get('constraint_message'), 'Rank Message')

        self.assertEqual(surv[3]['appearance'], 'overridden')

        self.assertEqual(surv[4]['type'], 'end group')
        self.assertIn('kuid', surv[4].keys())
        self.assertEqual(len(surv[4].keys()), 2)

    def test_score_conversion(self):
        result = convert_survey(score_s, items)
        surv = result['survey']
        self.assertEqual(len(surv), 5)
        self.assertEqual(surv[0]['appearance'], 'field-list')
        self.assertEqual(surv[0]['type'], 'begin group')
        self.assertEqual(surv[0]['relevant'], 'ghijkl')

        self.assertEqual(surv[1]['type'], 'select_one items')
        self.assertEqual(surv[1]['appearance'], 'label')
        self.assertEqual(surv[1].get('relevant', None), None)

        self.assertEqual(surv[2]['appearance'], 'list-nolabel')
        self.assertEqual(surv[2]['type'], 'select_one items')

        self.assertEqual(surv[3]['appearance'], 'overridden')

        self.assertEqual(surv[4]['type'], 'end group')
        self.assertIn('kuid', surv[4].keys())
        self.assertEqual(len(surv[4].keys()), 2)
