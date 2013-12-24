from django.shortcuts import render_to_response, HttpResponse
from django.template import RequestContext
from django.views.decorators.csrf import ensure_csrf_cookie
from django.contrib.auth.decorators import login_required
from models import SurveyDraft
from django.forms.models import model_to_dict
from rest_framework import viewsets
from serializers import SurveyDraftSerializer
import json
import utils


def csv_to_xform(request):
    csv_data = request.POST.get('txtImport')

    survey = utils.create_survey_from_csv_text(csv_data)

    response = HttpResponse(survey.to_xml(),
                            mimetype='application/force-download')
    response['Content-Disposition'] = 'attachment; filename=survey.xml'

    return response


def export_form_to_xform(request, id):
    survey = utils.create_survey_from_csv_text(SurveyDraft.objects.get(pk=id).body)

    response = HttpResponse(survey.to_xml(),
                            mimetype='application/force-download')

    response['Content-Disposition'] = 'attachment; filename=survey.xml'

    return response


@login_required
@ensure_csrf_cookie
def spa(request):
    if request.user.is_authenticated():
        user_details = {u'name': request.user.email,
                        u'gravatar': utils.gravatar_url(request.user.email)}
    else:
        user_details = {}
    return render_to_response("index.html",
                              context_instance=
                              RequestContext(request, {'user_details': json.dumps(user_details)}))


@login_required
def survey_drafts(request, sdid=0):
    if request.method == 'GET':
        if sdid > 0:
            return read_survey_draft(request, sdid)
        else:
            return list_survey_drafts(request)
    elif request.method == 'POST':
        return create_survey_draft(request)
    elif request.method == 'PUT':
        return update_survey_draft(request, sdid)


@login_required
def list_survey_drafts(request):
    ids = [dd['id']
           for dd in SurveyDraft.objects.filter(user=request.user).values("id")]
    return HttpResponse(json.dumps(ids))


@login_required
def create_survey_draft(request):

    raw_draft = json.loads(request.body)

    name = raw_draft.get('title', raw_draft.get('name'))

    csv_details = {u'user': request.user,
                   u'body': raw_draft.get("body"),
                   u'description': raw_draft.get("description"),
                   u'name': name}
    survey_draft = SurveyDraft.objects.create(**csv_details)
    return HttpResponse(json.dumps(model_to_dict(survey_draft)))


def update_survey_draft(request, sdid):
    raw_draft = json.loads(request.body)

    name = raw_draft.get('title', raw_draft.get('name'))

    survey_draft = SurveyDraft.objects.get(pk=sdid)

    survey_draft.body = raw_draft.get("body")
    survey_draft.description = raw_draft.get("description")
    survey_draft.name = name

    survey_draft.save()

    return HttpResponse(json.dumps(model_to_dict(survey_draft)))


@login_required
def read_survey_draft(request, sdid):
    survey_draft = SurveyDraft.objects.get(id=sdid)
    return HttpResponse(json.dumps(model_to_dict(survey_draft)))

# unrestful, but works.


def list_forms_for_user(request):
    survey_drafts = []
    if request.user.is_authenticated():
        for sd in request.user.survey_drafts.all():
            survey_drafts.append({u'title': sd.name,
                                  u'info': sd.description,
                                  u'icon': 'fa-file-o',
                                  u'iconBgColor': 'green',
                                  u'id': sd.id})
    return HttpResponse(json.dumps(survey_drafts))


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
    return HttpResponse(json.dumps(library_forms))


def jasmine_spec(request):
    return render_to_response("jasmine_spec.html")


class SurveyDraftViewSet(viewsets.ModelViewSet):
    model = SurveyDraft

    def get_queryset(self):
        user = self.request.user
        return SurveyDraft.objects.filter(user=user)

    serializer_class = SurveyDraftSerializer
