from django.shortcuts import render_to_response, HttpResponse
from django.core.context_processors import csrf
from django.views.decorators.csrf import ensure_csrf_cookie
from django.contrib.auth.decorators import login_required
from models import SurveyDraft
from django.forms.models import model_to_dict
import json
import utils

def main(self):
    return render_to_response("main.haml")

def csv_to_xform(request):
    csv_data = request.POST.get('txtImport')

    survey = utils.create_survey_from_csv_text(csv_data)

    response = HttpResponse(survey.to_xml(),mimetype='application/force-download')
    response['Content-Disposition'] = 'attachment; filename=survey.xml'

    return response

@ensure_csrf_cookie
def spa(request):
    return render_to_response("index.html")

@login_required
def list_survey_drafts(request):
    ids = [dd['id'] for dd in SurveyDraft.objects.filter(user=request.user).values("id")]
    return HttpResponse(json.dumps(ids))

@login_required
def create_survey_draft(request):
    csv_details = {u'user': request.user, \
        u'body': request.POST.get("body"), \
        u'description': request.POST.get("description"), \
        u'name': request.POST.get("name") }
    survey_draft = SurveyDraft.objects.create(**csv_details)
    return HttpResponse(survey_draft.id)

@login_required
def read_survey_draft(request, sdid):
    survey_draft = SurveyDraft.objects.get(id=sdid)
    return HttpResponse(json.dumps(model_to_dict(survey_draft)))
