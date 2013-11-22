import tempfile
from pyxform import create_survey_from_xls
def create_survey_from_csv_text(csv_text):
    with tempfile.NamedTemporaryFile(suffix=".csv") as csv_file:
        csv_file.write(csv_text)
        csv_file.flush()
        return create_survey_from_xls(csv_file.name)