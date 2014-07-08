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

def export_all_questions(request):
    queryset = SurveyDraft.objects.filter(user=request.user)
    queryset = queryset.exclude(asset_type=None)
    bodies = list(question.body.split('\n') for question in queryset)

    concentrated_questions = ['"survey",,,,,,,,,', ',"name","type","label","hint","required","relevant","default","constraint","constraint_message","calculation"']

    question_fields = concentrated_questions[1].split(',')

    for body in bodies:
        body.pop(0)
        current_question_fields = body.pop(0).split(',')
        current_question = body.pop(0).split(',')
        final_question = ['']
        for field in question_fields:
            if field is '':
                continue

            try:
                final_question.append(current_question[current_question_fields.index(field)])
            except ValueError:
                final_question.append('')

        concentrated_questions.append(','.join(final_question))

    concentrated_questions.append('"choices",,,')
    concentrated_questions.append('"","list name","name","label"')

    for body in bodies:
        if body[0] == '"choices",,,':
            while body[0] != '"settings",,':
                concentrated_questions.append(body.pop(0))

    concentrated_questions.append('"settings",,')
    concentrated_questions.append(',"form_title","form_id"')
    concentrated_questions.append(',"New form","new_form"')

    concentrated_csv = '\n'.join(concentrated_questions)

    from dkobo.koboform import pyxform_utils

    response = HttpResponse(pyxform_utils.convert_csv_to_xls(concentrated_csv), mimetype='application/vnd.ms-excel; charset=utf-8')
    response['Content-Disposition'] = 'attachment; filename=all_questions.xls'

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
            # create and validate the xform but ignore the results
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
def import_questions(request):
    """
    Imports an XLS or CSV file into the user's SurveyDraft list.
    Returns an error in JSON if the survey was not valid.
    """
    output = {}
    posted_file = request.FILES.get(u'files')
    response_code = 200
    if posted_file:
        #try:

        posted_file.seek(0)


        if posted_file.content_type in XLS_CONTENT_TYPES:
            csv = pyxform_utils.convert_xls_to_csv_string(posted_file)
        elif posted_file.content_type == "text/csv":
            csv = posted_file.read()
        else:
            raise Exception("Content-type not recognized: '%s'" % posted_file.content_type)

        csv_list = csv.split('"settings"\r\n')
        settings = csv_list.pop().split('\r\n')
        csv_list = csv_list.pop().split('"choices"\r\n')
        choices = csv_list.pop().split('\r\n')
        questions = csv_list.pop().split('\r\n')

        choices_field = choices.pop(0)

        survey_header = questions.pop(0)
        survey_fields_template = questions.pop(0)
        survey_fields = survey_fields_template.split(',')
        type_index = survey_fields.index('"type"')

        questions.pop()

        choices_header = '"choices",,,'
        settings_header = '"settings",,'

        question_lists = list()

        for question in questions:
            if '"start"' in question:
                break

            question_list = list([survey_header, survey_fields_template, question])
            if 'select_multiple' in question or 'select_one' in question:
                question_detail = question.split(',')
                choicelist_id = question_detail[type_index].split(' ')[1]
                choicelist = (choice for choice in choices if choicelist_id in choice)
                question_list.append(choices_header)
                question_list.append(choices_field)
                question_list.extend(choicelist)

            question_list.append(settings_header)
            question_list.extend(settings)

            question_lists.append(question_list)



        for question_list in question_lists:
            new_survey_draft = SurveyDraft.objects.create(**{
                u'body': '\n'.join(question_list),
                u'name': 'New Form',
                u'user': request.user,
                u'asset_type':'question'
            })

        output[u'survey_draft_id'] = new_survey_draft.id
        #except Exception, err:
        #response_code = 500
        #output[u'error'] = str(err)
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

    body = survey_draft.body.split('\n')

    title = request.DATA.get('title', False)
    id_string = request.DATA.get('id_string', False)

    form_settings=body.pop()

    if form_settings is u'':
        form_settings = body.pop() + '\n'
    form_settings_list=form_settings.split(',')

    if title and title != '':
        form_settings_list.pop(1)
        form_settings_list.insert(1, '"' + title + '"')
    if id_string and id_string != '':
        form_settings_list.pop(2)
        form_settings_list.insert(2, '"' + id_string + '"')

    body.append(','.join(form_settings_list))
    body = '\n'.join(body)

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
