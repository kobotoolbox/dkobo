#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.test import TestCase
# from lxml import etree
# from StringIO import StringIO
from django.contrib.auth.models import User
from django.test.client import Client
# from pyxform import xls2json_backends
# from dkobo.koboform.models import SurveyDraft, SurveyPreview
# from dkobo.koboform import pyxform_utils
# from dkobo.koboform import utils
import json


class CreateReadUpdateDeleteSurveyDraftsTests(TestCase):
    def setUp(self):
        test_user_credentials = {'username': 'user1', 'password': 'pass'}
        if User.objects.count() is 0:
            new_user = User(username=test_user_credentials['username'], email="user1@example.com")
            new_user.set_password(test_user_credentials['password'])
            new_user.save()
        # a client to test behavior when not logged in
        self.anonymousClient = Client()

        self.user = User.objects.all()[0]
        self.client = Client()
        self.client.post('/accounts/login/', test_user_credentials)

    def post_survey(self, client, survey={}):
        survey_dict = {u'name': "Test Form",
                        u'body': 'body',
                        u'description': 'description'}
        survey_dict.update(survey)
        return self.client.post('/api/survey_drafts', survey_dict)

    def test_anonymous_list(self):
        resp = self.anonymousClient.get('/api/survey_drafts')
        self.assertEqual(resp.status_code, 403)

    def test_empty_list(self):
        resp = self.client.get('/api/survey_drafts')
        self.assertEqual(resp.status_code, 200)
        # json_resp = json.loads(resp.content)
        self.assertEqual(len(resp.data), 0)

        rr = self.post_survey(self.client)
        print rr.content
        resp2 = self.client.get('/api/survey_drafts')
        self.assertEqual(len(resp2.data), 1)

    def test_create_survey_draft(self):
        # self.client.get
        self.assertEqual(User.objects.count(), 1)