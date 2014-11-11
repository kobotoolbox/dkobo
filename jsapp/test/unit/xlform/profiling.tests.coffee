define 'cs!test/unit/xlform/profiling.tests', [
          'cs!xlform/_model',
          ], (
              $model,
              )->

  describe "profiling tests", -> profilingTests.call(@, $model)

profilingTests = ($model)->

  it 'profiles Survey.load vs inputDeserializer.deserialize', () ->

    surveyCsv = """
    "survey"
    "","name","type","label","required","hint"
    "","New_Question","text","","true","New Question"
    "","New_Question_004","audio","","true","New Question"
    "","New_Question_001","text","New Question","true",""
    "","New_Question_001_001","text","New Question","true",""
    "","group_ui8jw40","begin group","Group","",""
    "","New_Question_002","text","New Question","true",""
    "","New_Question_002_001","text","New Question","true",""
    "","New_Question_003","text","New Question","true",""
    "","","end group","","",""
    "","start","start","","",""
    "","end","end","","",""
    "settings"
    "","form_title","form_id"
    "","New form","new_form"
    """

    i = 0

    console.time('survey')
    while i < 250
      $model.Survey.load(surveyCsv)
      i++

    console.timeEnd('survey')

    i = 0
    console.time('inputDeserializer')
    while i < 250
      $model.inputDeserializer.deserialize(surveyCsv)
      i++

    console.timeEnd('inputDeserializer')
