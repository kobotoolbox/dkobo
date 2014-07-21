import json
import requests
from guardian.shortcuts import assign_perm

from django.http import HttpResponseBadRequest, HttpResponse, HttpResponseRedirect
from django.conf import settings
from django.contrib.auth.decorators import login_required
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.authtoken.models import Token

from dkobo.koboform.models import SurveyDraft
from dkobo.koboform.serializers import ListSurveyDraftSerializer, DetailSurveyDraftSerializer
from dkobo.koboform import pyxform_utils, kobocat_integration

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


@login_required
@api_view(['GET', 'POST'])
def publish_survey_draft(request, pk, format=None):
    if not settings.KOBOCAT_SERVER:
        return Response({'error': 'KoBoCat Server not specified'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    try:
        survey_draft = SurveyDraft.objects.get(pk=pk, user=request.user)
    except SurveyDraft.DoesNotExist:
        return Response({'error': 'SurveyDraft not found'}, status=status.HTTP_404_NOT_FOUND)

    form_id_string = request.DATA.get('id_string', False)
    survey_draft._set_form_id_string(form_id_string, title=request.DATA.get('title', False))

    #(status_code, resp) = kobocat_integration.publish_survey_draft(survey_draft, "%s://%s:%s" % (settings.KOBOCAT_SERVER_PROTOCOL, \settings.KOBOCAT_SERVER, \settings.KOBOCAT_SERVER_PORT))

    _set_necessary_permissions(request.user)
    (token, is_new) = Token.objects.get_or_create(user=request.user)
    headers = {u'Authorization':'Token ' + token.key}

    payload = {u'text_xls_form': body}

    url = kobocat_integration._kobocat_url('/api/v1/forms')

    response = requests.post(url, headers=headers, data=payload)

    status_code = response.status_code
    resp = response.json()
    if 'formid' in resp:
        survey_draft.kobocat_published_form_id = resp[u'formid']
        survey_draft.save()
        serializer = DetailSurveyDraftSerializer(survey_draft)
        resp.update({
            u'message': 'Successfully published form',
            u'published_form_url': kobocat_integration._kobocat_url('/%s/forms/%s' % (request.user.username, resp.get('id_string')))
            })

    return Response(resp, status=status_code)

def _set_necessary_permissions(user):
    """
    defeats the point of permissions, yes. But might get things working for now until we understand
    the way kobocat uses permissions.
    """
    necessary_perms = {'logger': ['add_datadictionary', 'add_xform', 'change_datadictionary', \
                                    'change_xform', 'delete_datadictionary', 'delete_xform', \
                                    'report_xform', 'view_xform',]}
    for app, perms in necessary_perms.items():
        for perm in perms:
            assign_perm('%s.%s' % (app, perm), user)

def published_survey_draft_url(request, pk):
    try:
        survey_draft = SurveyDraft.objects.get(pk=pk, user=request.user)
    except SurveyDraft.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    username = survey_draft.user.name

    return HttpResponseRedirect(kobocat_integration._kobocat_url("/%s" % username))
