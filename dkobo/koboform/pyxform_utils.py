from pyxform import xls2json, xls2json_backends, builder
import StringIO

def create_survey_from_csv_text(csv_text, default_name='KoBoFormSurvey', default_language=u'default', warnings=None, ):
    workbook_dict = xls2json_backends.csv_to_dict(StringIO.StringIO(csv_text))
    dict_repr = xls2json.workbook_to_json(workbook_dict, default_name, default_language, warnings)
    dict_repr[u'name'] = dict_repr[u'id_string']
    return builder.create_survey_element_from_dict(dict_repr)
