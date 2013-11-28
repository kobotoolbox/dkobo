$ ->
  app = new SurveyApp({})
  $("#builder").html(app.render().$el)

  saveButton = $("<button>", id: "save", text: "Save", class: "btn btn-default")
  downloadPreviewButton = $("<button>", id: "preview", text: "Download Preview", class: "btn btn-default")

  saveButton.click ->
    if app.validateSurvey()
      csv_txt = app.survey.toCSV()

  downloadPreviewButton.click ->
    if app.validateSurvey()
      csv_text = app.survey.toCSV()
      $.post("/xform_preview", {csv_txt: csv_text}).done (r)->
        log "Download this XForm", r

  buttonWrap = app.$el.find(".buttons")
  downloadPreviewButton.appendTo(buttonWrap)
  saveButton.appendTo(buttonWrap)