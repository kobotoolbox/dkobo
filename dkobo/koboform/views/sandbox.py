from django.template import RequestContext
from django.conf import settings
from django.shortcuts import render_to_response, HttpResponse

def jasmine_spec(request):
    context = RequestContext(request)
    context['DEBUG'] = settings.DEBUG
    return render_to_response("jasmine_spec.html", context_instance=context)

def sandbox(request):
    context = RequestContext(request)
    context['DEBUG'] = settings.DEBUG
    context['run_jasmine'] = False
    context['include_coffeefile'] = "kobo/stylesheets/pages/form_builder.coffee"
    return render_to_response("sandbox.html", context_instance=context)
