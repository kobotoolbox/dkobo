from django.shortcuts import render_to_response, HttpResponse
from django.http import HttpResponseServerError
from django.template import RequestContext
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_exempt
from django.contrib.auth.decorators import login_required
from models import SurveyDraft, SurveyPreview
from django.forms.models import model_to_dict
from rest_framework import viewsets
from rest_framework.decorators import action
from serializers import SurveyDraftSerializer
import json
import utils


def csv_to_xform(request):
    csv_data = request.POST.get('txtImport')

    survey = utils.create_survey_from_csv_text(csv_data)
    survey_id_string = survey.id_string
    response = HttpResponse(survey.to_xml(),
                            mimetype='application/force-download')
    response['Content-Disposition'] = 'attachment; filename=%s.xml' % (survey_id_string)

    return response


def export_form(request, id):
    survey_draft = SurveyDraft.objects.get(pk=id)
    file_format = request.GET.get('format', 'xml')
    if file_format == "xml":
        xml = utils.create_survey_from_csv_text(survey_draft.body).to_xml()
        response = HttpResponse(xml, mimetype='application/force-download')
        response['Content-Disposition'] = 'attachment; filename=survey.xml'
        return response
    elif file_format == "xls":
        import pyxform_utils
        survey = survey_draft._pyxform_survey()
        xls_io = pyxform_utils.convert_csv_to_xls(survey_draft.body)
        xls_resp = HttpResponse(xls_io, mimetype='application/vnd.ms-excel; charset=utf-8')
        xls_resp['Content-Disposition'] = 'attachment; filename=%s.xls' % survey.id_string
        return xls_resp


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

@csrf_exempt
def survey_previews(request):
    contents = json.loads(request.body)
    if contents.get(u'body'):
        preview = SurveyPreview._get_or_create(csv=contents.get(u'body'))
        preview_dict = model_to_dict(preview)
        response = HttpResponse(json.dumps(preview_dict), content_type="application/json")
        response["Access-Control-Allow-Origin"] = "*"
        response["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS"
        response["Access-Control-Max-Age"] = "1000"
        response["Access-Control-Allow-Headers"] = "*"
        return response

@csrf_exempt
def get_survey_preview(request, unique_string):
    return HttpResponse(SurveyPreview.objects.get(unique_string=unique_string).xml, content_type="application/xml")

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
        library_forms.append({u'name': sd.name,
                              u'description': sd.description,
                              u'tags': [],
                              u'id': sd.id,
                              })
    return HttpResponse(json.dumps(library_forms))


def jasmine_spec(request):
    return render_to_response("jasmine_spec.html")

XLS_CONTENT_TYPES = ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]

@login_required
def import_survey_draft(request):
    """
    Imports an XLS or CSV file into the user's SurveyDraft list.
    Returns an error in JSON if the survey was not valid.
    """
    output = {}
    posted_file = request.FILES.get(u'files')
    response_code = 200
    if posted_file:
        import pyxform_utils
        try:
            # create and validate the xform but ignore the resultss
            pyxform_utils.convert_xls_to_xform(posted_file)
            output[u'xlsform_valid'] = True

            posted_file.seek(0)
            if posted_file.content_type in XLS_CONTENT_TYPES:
                csv = pyxform_utils.convert_xls_to_csv_string(posted_file)
            elif posted_file.content_type == "text/csv":
                csv = posted_file.read()
            else:
                raise Exception("Content-type not recognized: '%s'" % posted_file.content_type)

            new_survey_draft = SurveyDraft.objects.create(**{
                u'body': csv,
                u'name': posted_file.name,
                u'user': request.user
            })
            output[u'survey_draft_id'] = new_survey_draft.id
        except Exception, err:
            response_code = 500
            output[u'error'] = str(err)
    else:
        response_code = 204  #Error 204: No input
        output[u'error'] = "No file posted"
    return HttpResponse(json.dumps(output), content_type="application/json", status=response_code)


class SurveyDraftViewSet(viewsets.ModelViewSet):
    model = SurveyDraft

    def get_queryset(self):
        user = self.request.user
        return SurveyDraft.objects.filter(user=user)

    serializer_class = SurveyDraftSerializer

    @action(methods=['DELETE'])
    def delete_survey_draft(self, request, pk=None):
        draft = self.get_object()
        draft.delete()
