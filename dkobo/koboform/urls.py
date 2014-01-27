from django.conf.urls import patterns, url

from views import survey_drafts, jasmine_spec, survey_previews, get_survey_preview

urlpatterns = patterns(
    '',
    url(r'^survey_draft/(?P<sdid>\d+)$', survey_drafts),
    url(r'^survey_draft', survey_drafts),
    url(r'^survey_preview/(?P<unique_string>\S+)$', get_survey_preview, name=u'survey_preview'),
    url(r'^survey_preview', survey_previews),
    url(r'^jasmine_spec/$', jasmine_spec),
)
