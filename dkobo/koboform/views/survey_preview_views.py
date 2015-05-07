import json

from django.shortcuts import HttpResponse
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_exempt
from django.forms.models import model_to_dict
from dkobo.koboform.models import SurveyPreview
from dkobo.koboform.pyxform_utils import convert_csv_to_valid_xlsform_unicode_csv

@csrf_exempt
def survey_previews(request):
    output_dict = {}
    try:
        contents = json.loads(request.body)
    except Exception, e:
        output_dict[u'error'] = "JSON parse error: %s" % repr(e)

    try:
        if contents.get(u'body'):
            valid_csv = convert_csv_to_valid_xlsform_unicode_csv(contents.get(u'body'))
            preview = SurveyPreview._get_or_create(csv=valid_csv)
            output_dict.update(model_to_dict(preview))
        else:
            output_dict[u'error'] = "'body' field not found"
    except Exception, e:
        # error_type is not used, but may help us to provide a helpful
        # error message (e.g. on PyxformError)
        output_dict[u'error_type'] = type(e).__name__
        output_dict[u'error'] = e.message or str(e)

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
