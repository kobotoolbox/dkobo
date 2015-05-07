from pyxform import xls2json, xls2json_backends, builder, create_survey_from_xls
import StringIO
import xlrd
import xlwt
import json
import csv
import re
from tempfile import NamedTemporaryFile
from dkobo.koboform.kobo_to_xlsform import convert_any_kobo_features_to_xlsform_survey_structure

def _smart_unicode(maybe_utf):
    if isinstance(maybe_utf, unicode):
        return maybe_utf
    return unicode(maybe_utf, 'utf-8')

def create_survey_from_ss_struct(ss_struct, default_name='KoBoFormSurvey', default_language=u'default', warnings=None, ):
    dict_repr = xls2json.workbook_to_json(ss_struct, default_name, default_language, warnings)
    dict_repr[u'name'] = dict_repr[u'id_string']
    return builder.create_survey_element_from_dict(dict_repr)

def create_survey_from_csv_text(csv_text, default_name='KoBoFormSurvey', default_language=u'default', warnings=None, ):
    workbook_dict = xls2json_backends.csv_to_dict(StringIO.StringIO(csv_text.encode("utf-8")))
    return create_survey_from_ss_struct(workbook_dict, default_name, default_language, warnings)

def convert_xls_to_xform(xls_file, warnings=False):
    """
    This receives an XLS file object and runs it through
    pyxform to create and validate the survey.
    """
    survey = create_survey_from_xls(xls_file)
    xml = ""
    if warnings:
        with NamedTemporaryFile(suffix='.xml') as named_tmp:
            survey.print_xform_to_file(path=named_tmp.name, validate=True, warnings=warnings)
            named_tmp.seek(0)
            xml = named_tmp.read()
    else:
        xml = survey.to_xml()
    return xml

def summarize_survey(csv_survey, _type):
    if csv_survey == '':
        raise ValueError('''
            This survey draft is corrupted and can no longer be used, likely because of a recent bug in the cloning feature.
            If you no longer have access to the original, please contact us for help with recovery. Otherwise, please delete this draft.
            '''.strip())
    ss_struct = convert_csv_to_ss_structure(csv_survey)
    return summarize_survey_structure(ss_struct, _type)

def summarize_survey_structure(ss_structure, _type):
    valid_ss_structure = convert_any_kobo_features_to_xlsform_survey_structure(ss_structure)
    survey = create_survey_from_ss_struct(valid_ss_structure)
    if _type == 'question':
        question_type = survey.children[0].type
        label = survey.children[0].label
        if question_type == 'calculate':
            label = survey.children[0].calculation

        if isinstance(label, dict):
            _langs = label.keys()
            if 'default' in _langs:
                _langs.remove('default')
            label = label[_langs[0]]

        return {
            'type': 'select_multiple' if question_type == 'select all that apply' else question_type,
            'label': label,
            'options': [option.label for option in survey.children[0].children]
        }
    else:
        return {'form_id': survey.id_string}

def convert_xls_to_csv_string(xls_file_object, strip_empty_rows=True):
    """
    The goal: Convert an XLS file object to a CSV string.

    This draws on code from `pyxform.xls2json_backends` and `convert_file_to_csv_string`, however
    this works as it is expected (does not add extra sheets or perform misc conversions which are
    a part of `pyxform.xls2json_backends.xls_to_dict`.)
    """
    def _iswhitespace(string):
        return isinstance(string, basestring) and len(string.strip()) == 0

    def xls_value_to_unicode(value, value_type):
        """
        Take a xls formatted value and try to make a unicode string
        representation.
        """
        if value_type == xlrd.XL_CELL_BOOLEAN:
            return u"TRUE" if value else u"FALSE"
        elif value_type == xlrd.XL_CELL_NUMBER:
            #Try to display as an int if possible.
            int_value = int(value)
            if int_value == value:
                return unicode(int_value)
            else:
                return unicode(value)
        elif value_type is xlrd.XL_CELL_DATE:
            #Warn that it is better to single quote as a string.
            #error_location = cellFormatString % (ss_row_idx, ss_col_idx)
            #raise Exception(
            #   "Cannot handle excel formatted date at " + error_location)
            datetime_or_time_only = xlrd.xldate_as_tuple(
                value, workbook.datemode)
            if datetime_or_time_only[:3] == (0, 0, 0):
                # must be time only
                return unicode(datetime.time(*datetime_or_time_only[3:]))
            return unicode(datetime.datetime(*datetime_or_time_only))
        else:
            #ensure unicode and replace nbsp spaces with normal ones
            #to avoid this issue:
            #https://github.com/modilabs/pyxform/issues/83
            return unicode(value).replace(unichr(160), ' ')

    def _escape_newline_chars(cell):
        return re.sub(r'\r', '\\\\r', re.sub(r'\n', '\\\\n', cell))

    def _sheet_to_lists(sheet):
        result = []
        for row in range(0, sheet.nrows):
            row_results = []
            row_empty = True
            for col in range(0, sheet.ncols):
                value = sheet.cell_value(row, col)
                if isinstance(value, basestring):
                    value = _escape_newline_chars(value.strip())
                if (value is not None) and (not _iswhitespace(value)):
                    value = xls_value_to_unicode(value, sheet.cell_type(row, col))
                if value != "":
                    row_empty = False
                row_results.append(value)
            if not strip_empty_rows or not row_empty:
                result.append(row_results)
        return result

    workbook = xlrd.open_workbook(file_contents=xls_file_object.read())
    ss_structure = []
    for sheet in workbook.sheets():
        sheet_name = sheet.name
        sheet_contents = _sheet_to_lists(sheet)
        ss_structure.append([sheet_name, sheet_contents])
    return convert_ss_structure_to_csv(ss_structure)


def _dicts_to_lists(arr):
    cols = []
    if len(arr) == 0:
        return []
    if type(arr[0]) is list:
        cols = arr[0]
        arr.remove(arr[0])
    for row in arr:
        if isinstance(row, dict):
            for col in row.keys():
                if col not in cols:
                    cols.append(col)
    out = [cols]
    for row in arr:
        if type(row) is list:
            out.append(row)
        else:
            _row = dict(row)
            out_row = []
            for col in cols:
                out_row.append(_row.get(col, ''))
            out.append(out_row)
    return out



def convert_ss_structure_to_csv(ss_list):
    """
    Expects a data structure like this:
    [
        ["sheet_name1",
            [
                ["col1", "col2", "col3"],
                ["cell1", "cell2", "cell3"]
            ]
        ],
        ...
    ]
    and exports a csv like this:
    "sheet_name1",,,
    ,"col1","col2","col3"
    ,"cell1","cell2","cell3"
    ...
    """
    csv_out = StringIO.StringIO()
    csv_opts = {'quotechar':'"', 'doublequote':False, 'escapechar':'\\',
                'delimiter':',', 'quoting':csv.QUOTE_ALL}
    writer = csv.writer(csv_out, **csv_opts)
    if type(ss_list) == dict:
        ss_list = ss_list.items()
    for sheet_name, sheet_contents in ss_list:
        writer.writerow([sheet_name])
        sheet_contents_lists = _dicts_to_lists(sheet_contents)
        for row in sheet_contents_lists:
            writer.writerow([s.encode("utf-8") for s in ([""] + row)])
    return csv_out.getvalue()

def _add_contents_to_sheet(sheet, contents):
    cols = []
    for row in contents:
        for key in row.keys():
            if key not in cols:
                cols.append(key)
    for ci, col in enumerate(cols):
        sheet.write(0, ci, col)
    for ri, row in enumerate(contents):
        for ci, col in enumerate(cols):
            val = row.get(col, None)
            if val:
                sheet.write(ri+1, ci, val)

def convert_csv_to_xls(csv_repr):
    dict_repr = xls2json_backends.csv_to_dict(StringIO.StringIO(csv_repr.encode("utf-8")))
    return convert_dict_to_xls(dict_repr)

def convert_csv_to_ss_structure(csv_repr):
    dict_repr = dict(xls2json_backends.csv_to_dict(StringIO.StringIO(csv_repr.encode("utf-8"))))
    for key in dict_repr.keys():
        if re.match('.*_header$', key):
            del dict_repr[key]
    return dict_repr

def convert_dict_to_xls(ss_dict):
    workbook = xlwt.Workbook()
    for sheet_name in ss_dict.keys():
        # pyxform.xls2json_backends adds "_header" items for each sheet.....
        if not re.match(r".*_header$", sheet_name):
            cur_sheet = workbook.add_sheet(sheet_name)
            _add_contents_to_sheet(cur_sheet, ss_dict[sheet_name])
    string_io = StringIO.StringIO()
    workbook.save(string_io)
    string_io.seek(0)
    return string_io

def convert_csv_to_valid_xlsform_unicode_csv(csv_str):
    ss_struct = convert_csv_to_ss_structure(csv_str)
    valid_ss_structure = convert_any_kobo_features_to_xlsform_survey_structure(ss_struct)
    return unicode(convert_ss_structure_to_csv(valid_ss_structure), 'utf-8')

def validate_kobo_xlsform(posted_file, warnings=[]):
    '''
    used on import of survey_draft xls files, this will convert any kobo structures to
    valid xlsform rules and then build the xform to ensure the survey passes through
    pyxform's validator.
    '''
    unvalidated_csv_xlsform = _smart_unicode(convert_xls_to_csv_string(posted_file))
    ss_struct = convert_csv_to_ss_structure(unvalidated_csv_xlsform)
    valid_ss_structure = convert_any_kobo_features_to_xlsform_survey_structure(ss_struct)
    return create_survey_from_ss_struct(valid_ss_structure, warnings=warnings).to_xml()
