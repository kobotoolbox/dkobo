$ ->
  $("#new-survey").click (evt)->
    evt.preventDefault()
    $(evt.target).addClass("disabled")
    new SurveyApp({}).render().$el.appendTo("#builder")
