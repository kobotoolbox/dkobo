import json

from django.shortcuts import render_to_response, HttpResponse, HttpResponseRedirect
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
                                published_survey_draft_url, import_questions
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
    page_kobo_configs = {
        u'kobocatServer': kobocat_integration._kobocat_url('/'),
        u'previewServer': settings.KOBOFORM_PREVIEW_SERVER,
        u'enketoServer': settings.ENKETO_SERVER,
        u'enketoPreviewUri': settings.ENKETO_PREVIEW_URI,
        }
    if request.user.is_authenticated():
        context['user_details'] = json.dumps({u'name': request.user.email,
                        u'gravatar': utils.gravatar_url(request.user.email),
                        u'debug': settings.DEBUG,
                        u'username': request.user.username})
    else:
        context['user_details'] = "{}"
    context['page_kobo_configs'] = json.dumps(page_kobo_configs)
    return render_to_response("index.html", context_instance=context)

def kobocat_redirect(request, path=''):
    if kobocat_integration._is_enabled():
        if path:
            path = "/%s" % path
        url = kobocat_integration._kobocat_url(path)
        return HttpResponseRedirect(url)
    else:
        raise NotImplementedError("kobocat integration is not enabled. [No settings.KOBOCAT_URL]")
