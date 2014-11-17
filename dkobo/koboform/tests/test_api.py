#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.test import TestCase
from django.contrib.auth.models import User
from django.test.client import Client
import json

from dkobo.koboform.models import SurveyDraft

class CreateReadUpdateDeleteSurveyDraftsTests(TestCase):
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

    def post_survey(self, client, survey={}):
        survey_dict = {u'name': "Test Form",
                        u'body': 'body',
                        u'description': 'description'}
        survey_dict.update(survey)
        return self.client.post('/api/survey_drafts', json.dumps(survey_dict), \
                                content_type='application/json')

    def post_asset(self, client, survey={}):
        survey_dict = {u'name': "Test Form",
                        u'body': 'body',
                        u'asset_type': 'question'}
        survey_dict.update(survey)
        return self.client.post('/api/library_assets', json.dumps(survey_dict), \
                                content_type='application/json')

    def test_anonymous_list(self):
        resp = self.anonymousClient.get('/api/survey_drafts')
        self.assertEqual(resp.status_code, 403)

    def test_empty_list(self):
        resp = self.client.get('/api/survey_drafts')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data), 0)

        self.post_survey(self.client)
        resp2 = self.client.get('/api/survey_drafts')
        self.assertEqual(len(resp2.data), 1)

    def test_retrieve_survey(self):
        self.post_survey(self.client)

        resp = self.client.get('/api/survey_drafts')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.data[0]['id'], 1)

        resp = self.client.get('/api/survey_drafts/1')
        self.assertEqual(resp.data.get('id'), 1)

    def test_patch_survey(self):
        def make_body(question_label):
            return """survey,,,\n,type,name,label\n,text,q1,%s""" % question_label
        self.post_survey(self.client, {
            u'body': make_body("Question1")
        })
        resp = self.client.get('/api/survey_drafts')
        self.assertEqual(resp.data[0]['id'], 1)
        resp2 = self.client.patch('/api/survey_drafts/1', json.dumps({
            u'body': make_body("Question2")
        }), content_type='application/json')
        self.assertEqual(SurveyDraft.objects.get(id=1).body, make_body("Question2"))

    def test_library_assets(self):
        # post a library_asset (question)
        resp = self.client.get('/api/library_assets')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data.get('results')), 0)

        # ensure library_assets was incremented
        self.post_survey(self.client, {u'asset_type': 'question'})
        resp = self.client.get('/api/library_assets')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data.get('results')), 1)

        # ensure that survey_drafts was not incremented
        resp = self.client.get('/api/survey_drafts')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data), 0)

    def test_patch_asset(self):
        def make_body(question_label):
            return """survey,,,\n,type,name,label\n,text,q1,%s""" % question_label
        self.post_asset(self.client, {
            u'body': make_body("Question1")
        })
        resp = self.client.get('/api/library_assets')
        self.assertEqual(resp.data.get('results')[0]['id'], 1)
        resp2 = self.client.patch('/api/library_assets/1', json.dumps({
            u'body': make_body("Question2"),
            u'asset_type':'question'
        }), content_type='application/json')
        self.assertEqual(SurveyDraft.objects.get(id=1).body, make_body("Question2"))

    def test_library_assets_get_loaded_in_correct_order(self):
        def make_body(question_label):
            return """survey,,,\n,type,name,label\n,text,q1,%s""" % question_label

        self.post_asset(self.client, {
            u'body': make_body("Question1"),
            u'asset_type': 'question'
        })

        self.post_asset(self.client, {
            u'body': make_body("Question2"),
            u'asset_type': 'question'
        })

        self.post_asset(self.client, {
            u'body': make_body("Question3"),
            u'asset_type': 'question'
        })

        resp = self.client.get('/api/library_assets')
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.data.get('results')), 3)

        self.assertEqual(resp.data.get('results')[0].get('body'), make_body("Question3"))
        self.assertEqual(resp.data.get('results')[1].get('body'), make_body("Question2"))
        self.assertEqual(resp.data.get('results')[2].get('body'), make_body("Question1"))

