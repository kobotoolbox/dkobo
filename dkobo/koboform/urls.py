from django.conf.urls import patterns, url

import views

urlpatterns = patterns('',
    url(r'^survey_draft/list', views.list_survey_drafts),
    url(r'^survey_draft/new', views.create_survey_draft),
    url(r'^survey_draft/(?P<sdid>\d+)$', views.read_survey_draft),
    url(r'^jasmine_spec/$', views.jasmine_spec)
)
