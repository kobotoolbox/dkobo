define 'cs!xlform_model_view/model', [], ()->
  xlform_model: true
  reverse: (input)->
    # a dummy fn to test output
    "#{input}".split("").reverse().join("")
