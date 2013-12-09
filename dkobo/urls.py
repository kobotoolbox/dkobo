from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'dkobo.koboform.views.main', name='fb'),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^csv$', 'dkobo.koboform.views.csv_to_xform'),
    url(r'^accounts/', include('registration.backends.default.urls')),
    url(r'^account/', include('django.contrib.auth.urls')),
    url(r'^spa/$', 'dkobo.koboform.views.spa'),
    # fallback on koboform app-specific urls:
    url(r'^koboform/', include('dkobo.koboform.urls')),
)