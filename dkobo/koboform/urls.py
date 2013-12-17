from django.conf.urls import patterns, url

from views import survey_drafts

urlpatterns = patterns(
    '',
    url(r'^survey_draft/(?P<sdid>\d+)$', survey_drafts),
    url(r'^survey_draft', survey_drafts),
)
