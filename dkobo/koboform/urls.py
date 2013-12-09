from django.conf.urls import patterns, include, url

from views import survey_draft, create_survey_draft, \
	read_survey_draft, list_survey_drafts

urlpatterns = patterns('',
    url(r'^survey_draft/list', list_survey_drafts),
    url(r'^survey_draft/new', create_survey_draft),
    url(r'^survey_draft/(?P<sdid>\d+)$', read_survey_draft),
)