from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'dkobo.koboform.views.main', name='fb'),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^csv$', 'dkobo.koboform.views.csv_to_xform'),
)