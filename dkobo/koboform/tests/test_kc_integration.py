#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.test import TestCase
from django.contrib.auth.models import User
from django.test.client import Client
import json

from dkobo.koboform.models import SurveyDraft
from dkobo.koboform import kobocat_integration
from rest_framework.authtoken.models import Token

class PublishSurveyDraftToKoboCatInstall(TestCase):
    def setUp(self):
        test_user_credentials = {'username': 'user1', 'password': 'pass'}
        if User.objects.count() is 0:
            new_user = User(username=test_user_credentials['username'], email="user1@example.com")
            new_user.set_password(test_user_credentials['password'])
            new_user.save()
        self.anonymousClient = Client()

        self.user = User.objects.all()[0]
        self.client = Client()
        self.client.post('/accounts/login/', test_user_credentials)

    def test_publish_survey_draft_client_params(self):
        def make_body(question_label):
            return """survey,,,\n,type,name,label\n,text,q1,%s""" % question_label

        self.assertEqual(self.user.survey_drafts.count(), 0)
        survey_draft = self.user.survey_drafts.create(body=make_body("MyLabel"))
        (url, params, headers) = kobocat_integration._publish_survey_draft_params(survey_draft, "kobocat__org")
        self.assertEqual(url, "kobocat__org/api/v1/forms")
        self.assertEqual(params.keys(), ['text_xls_form'])
