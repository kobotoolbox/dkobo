from django.conf.urls import patterns, url

import views

urlpatterns = patterns(
    '',
    url(r'^survey_draft', views.survey_drafts),
    url(r'^survey_draft/(?P<sdid>\d+)$', views.survey_drafts),
    url(r'^jasmine_spec/$', views.jasmine_spec)
)
