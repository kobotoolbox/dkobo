from django.conf.urls import patterns, url

from views import read_survey_draft, survey_drafts

urlpatterns = patterns(
    '',
    url(r'^survey_draft/(?P<sdid>\d+)$', read_survey_draft),
    url(r'^survey_draft', survey_drafts),
)
