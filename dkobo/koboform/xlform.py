import re
import json
import subprocess


def split_apart_survey(scsv):
    return process_xlform(scsv, {'action': 'split_into_individual_surveys'})

def shrink_survey(scsv):
    return process_xlform(scsv, {'action': 'shrinkSurvey'})

def summarize_survey(scsv):
    return process_xlform(scsv, {'action': 'summarizeSurvey'})

def process_xlform(pp, opts={}):
    opts['type'] = opts.get('type', 'survey')
    jsargs = ["node", "jsapp/utils/process_xlform.js"]
    for key, val in opts.items():
        jsargs.append("--%s=%s" % (key, val))
    xlf_proccess = subprocess.Popen(jsargs, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    xlf_proccess.stdin.write(pp)
    return json.loads(xlf_proccess.communicate()[0])
