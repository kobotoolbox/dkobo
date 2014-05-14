###
# [inputDeserializer]
#  wrapper around methods for converting raw input into survey structure
# ______________________________________________________________________
###

define 'cs!xlform/model.inputDeserializer', [
        'underscore',
        'cs!xlform/csv',
        'cs!xlform/model.aliases',
        ], (
            _,
            csv,
            $aliases,
            )->
  inputDeserializer = (inp, ctx={})->
    r = deserialize inp, ctx
    validateParse(r, ctx)  if not ctx.error and ctx.validate
    r

  # [inputDeserializer.deserialize] parses csv string, json string,
  #  or object into survey object
  # -------------------------------
  deserialize = do ->
    _csv_to_params = (csv_repr)->
      cobj = csv.sheeted(csv_repr)
      out = {}

      out.survey = if (sht = cobj.sheet "survey") then sht.toObjects() else []
      out.choices = if (sht = cobj.sheet "choices") then sht.toObjects() else []
      if (sht = cobj.sheet "settings")
        out.settings = sht.toObjects()[0]

      out

    # returns: function
    (repr, ctx={})->
      if _.isString(repr)
        if repr.length > 0 and repr.match(/^\s*{.*}\s*$/)
          JSON.parse repr
        else
          _csv_to_params repr
      else if _.isObject repr
        repr
      else
        ``

  # [inputDeserializer.validateParse]
  #  ensure correct sheet names exist in imported surveys
  # ---------------------------------
  validateParse = do ->
    requiredSheetNameList = $aliases.q.requiredSheetNameList()

    # returns: function
    (repr, ctx={})->
      valid_with_sheet = false
      for sheetId in requiredSheetNameList
        if repr[sheetId]
          ctx.surveyType = sheetId
          valid_with_sheet = true
      ctx.settings = true  if repr['settings']
      ctx.choices = true  if repr['choices']
      unless valid_with_sheet
        sn = requiredSheetNameList.join(', ')
        ctx.error = "Missing a survey sheet [#{sn}]"
      !ctx.error

  inputDeserializer.validateParse = validateParse
  inputDeserializer.deserialize = deserialize
  inputDeserializer
