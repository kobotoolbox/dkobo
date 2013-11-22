from django.conf.urls import patterns, include, url

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'dkobo.formbuilder.views.main', name='fb'),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^csv$', 'dkobo.formbuilder.views.csv_to_xform', { "template": "sandbox-stub.html" }),
    url(r'^sandbox$', 'dkobo.formbuilder.views.sandbox')
)