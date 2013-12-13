from django.shortcuts import render_to_response, HttpResponse
from django.template import RequestContext
from django.core.context_processors import csrf
from django.views.decorators.csrf import ensure_csrf_cookie
from django.contrib.auth.decorators import login_required
from models import SurveyDraft
from django.forms.models import model_to_dict
import json
import utils
import json


def csv_to_xform(request):
    csv_data = request.POST.get('txtImport')

    survey = utils.create_survey_from_csv_text(csv_data)

    response = HttpResponse(survey.to_xml(), mimetype='application/force-download')
    response['Content-Disposition'] = 'attachment; filename=survey.xml'

    return response

@ensure_csrf_cookie
def spa(request):
    if request.user.is_authenticated():
        user_details = {u'name': request.user.email, 'gravatar': utils.gravatar_url(request.user.email)}
    else:
        user_details = {}
    return render_to_response("index.html", context_instance=RequestContext(request, {
        'user_details': json.dumps(user_details)}))

@login_required
def list_survey_drafts(request):
    ids = [dd['id'] for dd in SurveyDraft.objects.filter(user=request.user).values("id")]
    return HttpResponse(json.dumps(ids))

@login_required
def create_survey_draft(request):
    csv_details = {u'user': request.user,
                   u'body': request.POST.get("body"),
                   u'description': request.POST.get("description"),
                   u'name': request.POST.get("title")}
    survey_draft = SurveyDraft.objects.create(**csv_details)
    return HttpResponse(survey_draft.id)

@login_required
def read_survey_draft(request, sdid):
    survey_draft = SurveyDraft.objects.get(id=sdid)
    return HttpResponse(json.dumps(model_to_dict(survey_draft)))

# unrestful, but works.
def list_forms_for_user(request):
    survey_drafts = []
    if request.user.is_authenticated():
        for sd in request.user.survey_drafts.all():
            survey_drafts.append({u'title': sd.name,\
                    u'info': sd.description,
                    u'icon': 'fa-file-o',
                    u'iconBgColor': 'green'})
    return HttpResponse(json.dumps({u'list': survey_drafts}))

def list_forms_in_library(request):
    '''
    This is a placeholder for the accessor of surveys
    in the question library.
    '''
    library_forms = []
    for sd in SurveyDraft.objects.filter(in_question_library=True):
        library_forms.append({u'title': sd.name,
            u'info': sd.description,
            u'icon': 'fa-file-text-o',
            u'iconBgColor': 'teal',
            u'tags': []})
    return HttpResponse(json.dumps({u'list': library_forms}))