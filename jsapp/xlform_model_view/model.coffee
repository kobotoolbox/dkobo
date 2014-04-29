define 'cs!xlform_model_view/model', ['xlform_model_view/model_skipLogicParser'], (skipLogicParser)->
  xlform_model: true
  skipLogicParser: skipLogicParser
  reverse: (input)->
    # a dummy fn to test output
    "#{input}".split("").reverse().join("")
