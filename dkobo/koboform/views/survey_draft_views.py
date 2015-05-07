import json
import requests
import pyxform.survey_from
from guardian.shortcuts import assign_perm

from django.http import HttpResponseBadRequest, HttpResponse, HttpResponseRedirect
from django.conf import settings
from django.utils.encoding import smart_unicode
from django.contrib.auth.decorators import login_required
from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.authtoken.models import Token

from dkobo.koboform.models import SurveyDraft
from dkobo.koboform.serializers import ListSurveyDraftSerializer, DetailSurveyDraftSerializer
from dkobo.koboform.kobo_to_xlsform import convert_any_kobo_features_to_xlsform_survey_structure
from dkobo.koboform import pyxform_utils, kobocat_integration, xlform


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

# def export_all_questions(request):
#     queryset = SurveyDraft.objects.filter(user=request.user)
#     queryset = queryset.exclude(asset_type=None)
#     from dkobo.koboform import pyxform_utils
#     response = HttpResponse(pyxform_utils.convert_csv_to_xls(concentrated_csv), mimetype='application/vnd.ms-excel; charset=utf-8')
#     response['Content-Disposition'] = 'attachment; filename=all_questions.xls'
#     return response

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
    kwargs = {'pk': pk}
    if not request.user.is_superuser:
        kwargs['user'] = request.user

    try:
        survey_draft = SurveyDraft.objects.get(**kwargs)
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
            if key == 'tags':
                survey_draft.tags.clear()
                for val in value: survey_draft.tags.add(val)
            else:
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
def bulk_delete_questions(request):
    question_ids = json.loads(request.body)
    SurveyDraft.objects.filter(user=request.user).filter(id__in=question_ids).delete()
    return HttpResponse('')

@login_required
def import_survey_draft(request):
    """
    Imports an XLS or CSV file into the user's SurveyDraft list.
    Returns an error in JSON if the survey was not valid.
    """
    output = {}
    posted_file = request.FILES.get(u'files')
    response_code = 200
    if not posted_file:
        response_code = 204  # Error 204: No input
        output[u'error'] = "No file posted"
    elif posted_file.name.endswith('.xml'):
        warnings = []
        try:
            survey_object = pyxform.survey_from.xform(filelike_obj=posted_file, warnings=warnings)
            _csv = survey_object.to_csv(warnings=warnings, koboform=True).read()
            new_survey_draft = SurveyDraft.objects.create(**{
                u'body': smart_unicode(_csv),
                u'name': posted_file.name,
                u'user': request.user
            })
            output[u'survey_draft_id'] = new_survey_draft.id
        except Exception, err:
            response_code = 500
            output[u'error'] = err.message or str(err)
        output[u'warnings'] = warnings
    else:
        try:
            # create and validate the xform but ignore the results
            warnings = []
            pyxform_utils.validate_kobo_xlsform(posted_file, warnings=warnings)
            output[u'xlsform_valid'] = True

            posted_file.seek(0)
            if posted_file.content_type in XLS_CONTENT_TYPES:
                _csv = pyxform_utils.convert_xls_to_csv_string(posted_file)
            elif posted_file.content_type == "text/csv":
                _csv = posted_file.read()
            else:
                raise Exception("Content-type not recognized: '%s'" % posted_file.content_type)

            new_survey_draft = SurveyDraft.objects.create(**{
                u'body': smart_unicode(_csv),
                u'name': posted_file.name,
                u'user': request.user
            })
            output[u'survey_draft_id'] = new_survey_draft.id
        except Exception, err:
            response_code = 500
            output[u'error'] = err.message or str(err)
    return HttpResponse(json.dumps(output), content_type="application/json", status=response_code)


@login_required
def import_questions(request):
    """
    Imports an XLS or CSV file into the user's SurveyDraft list.
    Returns an error in JSON if the survey was not valid.
    """
    output = {}
    posted_file = request.FILES.get(u'files')
    response_code = 200
    if posted_file:
        posted_file.seek(0)

        if posted_file.content_type in XLS_CONTENT_TYPES:
            imported_sheets_as_csv = pyxform_utils.convert_xls_to_csv_string(posted_file)
        elif posted_file.content_type == "text/csv":
            imported_sheets_as_csv = posted_file.read()
        else:
            raise Exception("Content-type not recognized: '%s'" % posted_file.content_type)

        split_surveys = xlform.split_apart_survey(imported_sheets_as_csv)

        new_survey_drafts = []
        for _split_survey in split_surveys:
            sd = SurveyDraft(name='New Form',
                             body=_split_survey[0],
                             user=request.user,
                             asset_type='question')
            sd._summarize()
            new_survey_drafts.append(sd)
        SurveyDraft.objects.bulk_create(new_survey_drafts)

        output[u'survey_draft_id'] = -1
    else:
        response_code = 204  # Error 204: No input
        output[u'error'] = "No file posted"
    return HttpResponse(json.dumps(output), content_type="application/json", status=response_code)

@login_required
@api_view(['GET', 'POST'])
def publish_survey_draft(request, pk, format=None):
    if not kobocat_integration._is_enabled():
        return Response({'error': 'KoBoCat Server not specified'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    try:
        survey_draft = SurveyDraft.objects.get(pk=pk, user=request.user)
    except SurveyDraft.DoesNotExist:
        return Response({'error': 'SurveyDraft not found'}, status=status.HTTP_404_NOT_FOUND)

    # convert csv to ss_struct
    ss_struct = pyxform_utils.convert_csv_to_ss_structure(survey_draft.body)
    form_id_string = request.DATA.get('id_string', False)

    # set the form_id based on the payload
    if 'settings' not in ss_struct:
        ss_struct['settings'] = []
    if len(ss_struct['settings']) == 0:
        ss_struct['settings'].append({})
    ss_struct['settings'][0]['form_id'] = form_id_string

    # convert kobo-specific data structures into valid xlsform (e.g. score, rank)
    xlsform_ss_struct = convert_any_kobo_features_to_xlsform_survey_structure(ss_struct)
    valid_xlsform_csv_repr = pyxform_utils.convert_ss_structure_to_csv(xlsform_ss_struct)
    _set_necessary_permissions(request.user)
    (token, is_new) = Token.objects.get_or_create(user=request.user)
    headers = {u'Authorization':'Token ' + token.key}

    payload = {u'text_xls_form': valid_xlsform_csv_repr}
    try:
        url = kobocat_integration._kobocat_url('/api/v1/forms', internal=True)
        response = requests.post(url, headers=headers, data=payload)
        status_code = response.status_code
        resp = response.json()
    except Exception, e:
        resp = {'status_code': 504, 'detail': str(e)}
        status_code = 504

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

