from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'dkobo.koboform.views.spa', name='spa'),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^csv$', 'dkobo.koboform.views.csv_to_xform'),
    url(r'^accounts/', include('registration.backends.default.urls')),
    url(r'^account/', include('django.contrib.auth.urls')),
    url(r'^spa/$', 'dkobo.koboform.views.spa'),
    # fallback on koboform app-specific urls:
    url(r'^koboform/', include('dkobo.koboform.urls')),
    # we should re-think a RESTful accessor for the URLs below
    url(r'^question_library_forms/$', 'dkobo.koboform.views.list_forms_in_library'),
    url(r'^survey_drafts/$', 'dkobo.koboform.views.list_forms_for_user'),
)