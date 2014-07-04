from django.conf.urls import patterns, include, url
from django.contrib import admin
from rest_framework import routers
# from koboform.views import SurveyDraftViewSet
from koboform.api import SurveyDraftViewSet, LibraryAssetViewset


router = routers.DefaultRouter(trailing_slash=False)
router.register(r'survey_drafts', SurveyDraftViewSet, 'SurveyDraft')
router.register(r'library_assets', LibraryAssetViewset, 'LibraryAsset')

admin.autodiscover()

urlpatterns = patterns(
    '',
    url(r'^api/survey_drafts/(?P<pk>\d+)$', 'dkobo.koboform.views.survey_draft_detail'),
    url(r'^api/library_assets/(?P<pk>\d+)$', 'dkobo.koboform.views.survey_draft_detail'),
    url(r'^api/survey_drafts/(?P<pk>\d+)/publish$', 'dkobo.koboform.views.publish_survey_draft'),
    url(r'^api/survey_drafts/(?P<pk>\d+)/published$', 'dkobo.koboform.views.published_survey_draft_url'),
    url(r'^api/', include(router.urls)),
    url(r'^kobocat$', 'dkobo.koboform.views.kobocat_redirect'),
    url(r'^kobocat/(?P<path>\S*)$', 'dkobo.koboform.views.kobocat_redirect'),
    url(r'^$', 'dkobo.koboform.views.spa', name='spa'),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^csv$', 'dkobo.koboform.views.csv_to_xform'),
    url(r'^accounts/logout/', 'django.contrib.auth.views.logout', {'next_page': '/'}),
    url(r'^accounts/', include('registration.backends.default.urls')),
    url(r'^account/', include('django.contrib.auth.urls')),
    # fallback on koboform app-specific urls:
    url(r'^koboform/', include('dkobo.koboform.urls')),
    # we should re-think a RESTful accessor for the URLs below
    url(r'^import_survey_draft$', 'dkobo.koboform.views.survey_draft_views.import_survey_draft'),
    url(r'^import_questions$', 'dkobo.koboform.views.survey_draft_views.import_questions'),
    url(r'^forms/(?P<id>\d+)', 'dkobo.koboform.views.export_form'),
    url(r'^assets/(\d+)', 'dkobo.koboform.views.export_form'),
    url(r'^assets', 'dkobo.koboform.views.export_all_questions'),
)
