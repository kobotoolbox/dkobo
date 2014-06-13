import json

from django.shortcuts import HttpResponse
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_exempt
from django.forms.models import model_to_dict

from dkobo.koboform.models import SurveyPreview


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
