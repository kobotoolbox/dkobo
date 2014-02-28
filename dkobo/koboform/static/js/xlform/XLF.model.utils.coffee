XLF.createSurveyFromCsv = (csv_repr)->
  csv.settings.parseFloat = false

  cobj = csv.sheeted(csv_repr)
  $survey = if (sht = cobj.sheet "survey") then sht.toObjects() else []
  $choices = if (sht = cobj.sheet "choices") then sht.toObjects() else []

  if (settingsSheet = cobj.sheet "settings")
    $settings = settingsSheet.toObjects()[0]

  new XLF.Survey(survey: $survey, choices: $choices, settings: $settings)

XLF.txtid = ()->
  # a is text
  # b is numeric or text
  # c is mishmash
  o = 'AAnCAnn'.replace /[AaCn]/g, (c)->
    randChar= ()->
      charI = Math.floor(Math.random()*52)
      charI += (if charI <= 25 then 65 else 71)
      String.fromCharCode charI

    r = Math.random()
    if c is 'a'
      randChar()
    else if c is 'A'
      String.fromCharCode 65+(r*26|0)
    else if c is 'C'
      newI = Math.floor(r*62)
      if newI > 52 then (newI - 52) else randChar()
    else if c is 'n'
      Math.floor(r*10)
  o.toLowerCase()

XLF.parseHelper =
  parseSkipLogic: (collection, value, parent_row) ->
    collection.meta.set("rawValue", value)
    try
      parsedValues = XLF.skipLogicParser(value)
      collection.reset()
      collection.parseable = true
      for crit in parsedValues.criteria
        opts = {
          name: crit.name
          expressionCode: crit.operator
        }
        if crit.operator is "multiplechoice_selected"
          opts.criterionOption = collection.getSurvey().findRowByName(crit.name).getList().options.get(crit.response_value)
        else
          opts.criterion = crit.response_value
        collection.add(opts, silent: true, _parent: parent_row)
      if parsedValues.operator
        collection.meta.set("delimSelect", parsedValues.operator.toLowerCase())
      ``
    catch e
      collection.parseable = false

XLF.sluggifyLabel = (str, other_names=[])->
  attempt_base = str.replace(/\s+$/, "")
                  .replace(/^\s+/, "")
                  .replace(/\s/g, "_")
                  .replace(/\W/g, "")
                  .replace(/[_]+/g, "_")
  names_lc = (name.toLowerCase()  for name in other_names)
  if attempt_base.length is 0
    return false
  else if attempt_base[0].match(/\d/)
    attempt_base = "_#{attempt_base}"
  attempt = attempt_base
  increment = 0
  while attempt.toLowerCase() in names_lc
    increment++
    increment_str = if increment < 1000 then ("00"+increment).slice(-4) else increment_str
    attempt = "#{attempt_base}_#{increment_str}"
  attempt

XLF.sluggify = (str)->
  # Convert text to a slug/xml friendly format.
  str.toLowerCase().replace(/\s/g, '_').replace(/\W/g, '').replace(/[_]+/g, "_")
