$ ->
    app = new SurveyApp({})
    $("#builder").html(app.render().$el)

    saveButton = $("<button>", id: "save", text: "Save", class: "btn btn-default")
    downloadPreviewButton = $("<button>", id: "preview", text: "Download Preview", class: "btn btn-default")

    buttonWrap = app.$el.find(".buttons")
    downloadPreviewButton.appendTo(buttonWrap)
    saveButton.appendTo(buttonWrap)