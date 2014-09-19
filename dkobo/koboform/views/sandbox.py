from django.template import RequestContext
from django.conf import settings
from django.shortcuts import render_to_response, HttpResponse

def jasmine_spec(request):
    context = RequestContext(request)
    context['DEBUG'] = settings.DEBUG
    if settings.LIVE_RELOAD:
        context['livereload_address'] = "http://%s:35729/livereload.js" % request.META['REMOTE_ADDR']
    return render_to_response("jasmine_spec.html", context_instance=context)

def sandbox(request):
    context = RequestContext(request)
    context['DEBUG'] = settings.DEBUG
    if settings.LIVE_RELOAD:
        context['livereload_address'] = "http://%s:35729/livereload.js" % request.META['REMOTE_ADDR']
    context['run_jasmine'] = False
    context['include_coffeefile'] = "kobo/stylesheets/pages/form_builder.coffee"
    return render_to_response("sandbox.html", context_instance=context)
