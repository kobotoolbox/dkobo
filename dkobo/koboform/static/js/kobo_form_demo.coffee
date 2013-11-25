$ ->
  $("#new-survey").click (evt)->
    evt.preventDefault()
    $(evt.target).addClass("disabled")
    $("#builder").html(new SurveyApp({}).render().$el)
