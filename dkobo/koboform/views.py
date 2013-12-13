from django.shortcuts import render_to_response, HttpResponse
from django.core.context_processors import csrf
from django.views.decorators.csrf import ensure_csrf_cookie
import utils
import json

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

def list_forms_in_library(request):
    '''
    This is a placeholder for the accessor of surveys
    in the question library.
    '''
    return HttpResponse("[]")
