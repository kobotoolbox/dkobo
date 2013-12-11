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
	return HttpResponse(json.dumps([{
            'title': 'Safety and Security',
            'info': 'Last modified yesterday at 5:03pm by Leroy Jenkins',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': 'Advanced',
            'tag2': ''
        },
        {
            'title': 'Educational Resources',
            'info': 'Last modified yesterday at 1:42pm by Rod Stewart',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': '',
            'tag2': ''
        },
        {
            'title': 'Food Supply Near Water Supply',
            'info': 'Last modified yesterday at 11:29am by Cat Stevens',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': 'Demographics',
            'tag2': 'Basic Questions'
        },
        {
            'title': 'Local Water Supply Survey',
            'info': 'Last modified yesterday at 8:50am by Katt Williams',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': 'Demographics',
            'tag2': ''
        }
    ]))
