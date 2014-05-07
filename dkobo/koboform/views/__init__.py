from django.shortcuts import render_to_response, HttpResponse, get_object_or_404
from django.http import HttpResponseBadRequest
from django.core.exceptions import PermissionDenied
from django.template import RequestContext
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_exempt
from django.contrib.auth.decorators import login_required
from dkobo.koboform.models import SurveyDraft, SurveyPreview
from django.forms.models import model_to_dict
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.conf import settings

from dkobo.koboform.serializers import ListSurveyDraftSerializer, DetailSurveyDraftSerializer
from dkobo.koboform import utils

import json


def csv_to_xform(request):
    csv_data = request.POST.get('txtImport')

    survey = utils.create_survey_from_csv_text(csv_data)
    response = HttpResponse(survey.to_xml(),
                            mimetype='application/force-download')
    response['Content-Disposition'] = 'attachment; filename=%s.xml' % (survey.id_string)

    return response


def export_form(request, id):
    survey_draft = SurveyDraft.objects.get(pk=id)
    file_format = request.GET.get('format', 'xml')
    if file_format == "xml":
        contents = survey_draft.to_xml()
        mimetype = 'application/force-download'
        # content_length = len(contents) + 2 # the length of the string != the length of the file
    elif file_format == "xls":
        contents = survey_draft.to_xls()
        mimetype = 'application/vnd.ms-excel; charset=utf-8'
        # contents.read()
        # content_length = contents.tell()
        # contents.seek(0)
    elif file_format == "csv":
        contents = survey_draft.body
        mimetype = 'text/csv; charset=utf-8'
        # content_length = len(contents)
    else:
        return HttpResponseBadRequest(
            "Format not supported: '%s'. Supported formats are [xml,xls,csv]." % file_format)
    response = HttpResponse(contents, mimetype=mimetype)
    response['Content-Disposition'] = 'attachment; filename=%s.%s' % (survey_draft.id_string,
                                                                      file_format)
    # response['Content-Length'] = content_length
    return response


@login_required
@ensure_csrf_cookie
def spa(request):
    context = RequestContext(request)
    if request.user.is_authenticated():
        context['user_details'] = json.dumps({u'name': request.user.email,
                        u'gravatar': utils.gravatar_url(request.user.email)})
    else:
        context['user_details'] = "{}"
    context['DEBUG'] = settings.DEBUG
    return render_to_response("index.html", context_instance=context)

# @login_required
# def survey_drafts(request, sdid=0):
#     if request.method == 'GET':
#         if sdid > 0:
#             return read_survey_draft(request, sdid)
#         else:
#             return list_survey_drafts(request)
#     elif request.method == 'POST':
#         return create_survey_draft(request)
#     elif request.method == 'PUT':
#         return update_survey_draft(request, sdid)


@csrf_exempt
def survey_previews(request):
    output_dict = {}
    try:
        contents = json.loads(request.body)
    except Exception, e:
        output_dict[u'error'] = "JSON parse error: %s" % repr(e)

    try:
        if contents.get(u'body'):
            preview = SurveyPreview._get_or_create(csv=contents.get(u'body'))
            output_dict.update(model_to_dict(preview))
        else:
            output_dict[u'error'] = "'body' field not found"
    except Exception, e:
        output_dict[u'error'] = repr(e)

    response = HttpResponse(json.dumps(output_dict))
    response_options = {'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*',
                        'Access-Control-Max-Age': '1000',
                        'Access-Control-Allow-Headers': '*'}
    for k, v in response_options.items():
        response[k] = v
    return response


@csrf_exempt
def get_survey_preview(request, unique_string):
    return HttpResponse(
        SurveyPreview.objects.get(unique_string=unique_string).xml,
        content_type="application/xml")

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

@login_required
@api_view(['GET', 'PUT', 'DELETE', 'PATCH'])
def survey_draft_detail(request, pk, format=None):
    try:
        survey_draft = SurveyDraft.objects.get(pk=pk, user=request.user)
    except SurveyDraft.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = DetailSurveyDraftSerializer(survey_draft)
        return Response(serializer.data)

    elif request.method == 'PUT':
        serializer = DetailSurveyDraftSerializer(survey_draft, data=request.DATA)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'PATCH':
        for key, value in request.DATA.items():
            survey_draft.__setattr__(key, value)
        survey_draft.save()
        return Response(DetailSurveyDraftSerializer(survey_draft).data)

    elif request.method == 'DELETE':
        survey_draft.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


def jasmine_spec(request):
    context = RequestContext(request)
    context['DEBUG'] = settings.DEBUG
    context['run_jasmine'] = True
    context['include_coffeefile'] = "test/unit/SkipLogic.Tests.coffee"
    # context['include_js'] = "test/unit/Validator.Tests.js"
    return render_to_response("jasmine_spec.html", context_instance=context)

XLS_CONTENT_TYPES = [
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/octet-stream",
]

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
        import dkobo.koboform.pyxform_utils
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
        response_code = 204  # Error 204: No input
        output[u'error'] = "No file posted"
    return HttpResponse(json.dumps(output), content_type="application/json", status=response_code)
