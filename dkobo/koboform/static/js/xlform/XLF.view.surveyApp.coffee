# class @SurveyApp extends Backbone.View

class @SurveyApp extends Backbone.View
  className: "formbuilder-wrap container"
  events:
    "click .js-delete-row": "clickRemoveRow"
    "click #xlf-preview": "previewButtonClick"
    "click #csv-preview": "previewCsv"
    "click #xlf-download": "downloadButtonClick"
    "click #save": "saveButtonClick"
    "click #publish": "publishButtonClick"
    "update-sort": "updateSort"

  initialize: (options)->
    if options.survey and (options.survey instanceof XLF.Survey)
      @survey = options.survey
    else
      @survey = new XLF.Survey(options)

    @rowViews = new Backbone.Model()

    @survey.rows.on "add", @reset, @
    @survey.rows.on "remove", @reset, @
    @survey.on "row-detail-change", (row, key, val, ctxt)=>
      evtCode = "row-detail-change-#{key}"
      @$(".on-#{evtCode}").trigger(evtCode, row, key, val, ctxt)
    @$el.on "choice-list-update", (evt, clId) =>
      $(".on-choice-list-update[data-choice-list-cid='#{clId}']").trigger("rebuild-choice-list")

    @onPublish = options.publish || $.noop
    @onSave = options.save || $.noop
    @onPreview = options.preview || $.noop

    $(window).on "keydown", (evt)=>
      @onEscapeKeydown(evt)  if evt.keyCode is 27
  updateSort: (evt, model, position)->
    # inspired by this:
    # http://stackoverflow.com/questions/10147969/saving-jquery-ui-sortables-order-to-backbone-js-collection
    @survey.rows.remove(model)
    @survey.rows.each (m, index)->
      m.ordinal = if index >= position then (index + 1) else index
    model.ordinal = position
    @survey.rows.add(model, at: position)
    ``

  render: ()->
    @$el.removeClass("content--centered").removeClass("content")
    @$el.html viewTemplates.surveyApp @survey

    @survey.settings.on 'validated:invalid', (model, validations) ->
      for key, value of validations
          break

    @formEditorEl = @$(".-form-editor")
    @$(".editor-message .expanding-spacer-between-rows .add-row-btn").click (evt)=>
      if !@emptySurveyXlfRowSelector
        @emptySurveyXlfRowSelector = new XLF.RowSelector(el: @$el.find(".expanding-spacer-between-rows").get(0), survey: @survey)
      @emptySurveyXlfRowSelector.expand()

    viewUtils.makeEditable @, @survey.settings, '.form-title', property:'form_title'

    # see this page for info on what should be in a form_id
    # http://opendatakit.org/help/form-design/guidelines/
    viewUtils.makeEditable @, @survey.settings, '.form-id', property:'form_id', transformFunction:XLF.sluggify
    # @.survey.on 'change:form_id', _.bind viewUtils.handleChange('form_id', XLF.sluggify), @

    addOpts = @$("#additional-options")
    for detail in @survey.surveyDetails.models
      addOpts.append((new XLF.SurveyDetailView(model: detail)).render().el)

    @reset()

    @formEditorEl.sortable({
        axis: "y"
        cancel: "button,div.add-row-btn,.well,ul.list-view,li.editor-message, .editableform, .row-extras"
        cursor: "move"
        distance: 5
        items: "> li"
        placeholder: "placeholder"
        opacity: 0.9
        scroll: false
        stop: (evt, ui)->
          itemSet = ui.item.parent().find("> .xlf-row-view")
          ui.item.trigger "drop", itemSet.index(ui.item)
        activate: (evt, ui)=>
          @formEditorEl.addClass("insort")
          ui.item.addClass("sortable-active")
        deactivate: (evt,ui)=>
          @formEditorEl.removeClass("insort")
          ui.item.removeClass("sortable-active")
      })
    @

  validateSurvey: ()->
    true

  previewCsv: ->
    scsv = @survey.toCSV()
    console?.clear()
    log scsv
    ``

  reset: ->
    fe = @formEditorEl
    isEmpty = true
    fn = (row)=>
      isEmpty = false
      unless (xlfrv = @rowViews.get(row.cid))
        @rowViews.set(row.cid, new XLF.RowView(model: row, surveyView: @))
        xlfrv = @rowViews.get(row.cid)

      $el = xlfrv.render().$el
      if $el.parents(@$el).length is 0
        @formEditorEl.append($el)

    @survey.forEachRow(fn, includeErrors: true)

    @formEditorEl.find(".empty").css("display", if isEmpty then "" else "none")
    viewUtils.reorderElemsByData(".xlf-row-view", @$el, "row-index")
    ``

  clickRemoveRow: (evt)->
    evt.preventDefault()
    if confirm("Are you sure you want to delete this question? This action cannot be undone.")
      $et = $(evt.target)
      rowId = $et.parents("li").data("rowId")
      rowEl = $et.parents("li").eq(0)

      matchingRow = @survey.rows.find (row)-> row.cid is rowId

      if !matchingRow
        throw new Error("Matching row was not found.")

      @survey.rows.remove matchingRow
      # this slideUp is for add/remove row animation
      rowEl.slideUp 175, "swing"

  onEscapeKeydown: -> #noop. to be overridden
  previewButtonClick: (evt)->
    if evt.shiftKey #and evt.altKey
      evt.preventDefault()
      viewUtils.debugFrame @survey.toCSV()
      @onEscapeKeydown = viewUtils.debugFrame.close
    else
      XLF.enketoIframe.fromCsv @survey.toCSV(),
        previewServer: "http://kfdev.kobotoolbox.org"
        onSuccess: => @onEscapeKeydown = XLF.enketoIframe.close
        onError: (errArgs...)=>
          @alert errArgs
    ``

  alert: (message) ->
      $('.alert-modal').text(message).dialog('option', {
          title: 'Error'
          width: 500
      }).dialog 'open'
  downloadButtonClick: (evt)->
    # Download = save a CSV file to the disk
    surveyCsv = @survey.toCSV()
    if surveyCsv
      evt.target.href = "data:text/csv;charset=utf-8,#{encodeURIComponent(@survey.toCSV())}"
  saveButtonClick: (evt)->
    # Save = store CSV in local storage.
    @onSave.apply(@, arguments)
  publishButtonClick: (evt)->
    # Publish = trigger publish action (ie. post to formhub)
    @onPublish.apply(@, arguments)

class @SurveyTemplateApp extends Backbone.View
  events:
    "click .js-start-survey": "startSurvey"
  initialize: (@options)->
  render: ()->
    @$el.addClass("content--centered").addClass("content")
    @$el.html viewTemplates.surveyTemplateApp()
    @
  startSurvey: ->
    new SurveyApp(@options).render()
