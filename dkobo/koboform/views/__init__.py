import json

from django.shortcuts import render_to_response, HttpResponse
from django.template import RequestContext
from django.views.decorators.csrf import ensure_csrf_cookie
from django.contrib.auth.decorators import login_required
from django.conf import settings

from dkobo.koboform import utils
from dkobo.koboform import pyxform_utils
from dkobo.koboform import kobocat_integration

from sandbox import jasmine_spec, sandbox
from survey_draft_views import ListSurveyDraftSerializer, DetailSurveyDraftSerializer, \
                                export_form, create_survey_draft, survey_draft_detail, \
                                import_survey_draft, publish_survey_draft, \
                                published_survey_draft_url
from survey_preview_views import survey_previews, get_survey_preview

def csv_to_xform(request):
    csv_data = request.POST.get('txtImport')

    survey = utils.create_survey_from_csv_text(csv_data)
    response = HttpResponse(survey.to_xml(),
                            mimetype='application/force-download')
    response['Content-Disposition'] = 'attachment; filename=%s.xml' % (survey.id_string)

    return response

@login_required
@ensure_csrf_cookie
def spa(request):
    context = RequestContext(request)
    page_kobo_configs = { u'kobocatServer': kobocat_integration._kobocat_url('/') }
    if request.user.is_authenticated():
        context['user_details'] = json.dumps({u'name': request.user.email,
                        u'gravatar': utils.gravatar_url(request.user.email),
                        u'debug': settings.DEBUG})
    else:
        context['user_details'] = "{}"
    context['livereload_address'] = "http://%s:35729/livereload.js" % request.META['REMOTE_ADDR']
    context['DEBUG'] = settings.DEBUG
    context['page_kobo_configs'] = json.dumps(page_kobo_configs)
    return render_to_response("index.html", context_instance=context)

