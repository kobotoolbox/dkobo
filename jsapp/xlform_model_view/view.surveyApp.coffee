define 'cs!xlform/view.surveyApp', [
        'backbone',
        'cs!xlform/model.survey',
        'cs!xlform/model.utils',
        'cs!xlform/view.templates',
        'cs!xlform/view.surveyDetails',
        'cs!xlform/view.rowSelector',
        'cs!xlform/view.row',
        'cs!xlform/view.pluggedIn.backboneView',
        'cs!xlform/view.utils',
        ], (
            Backbone,
            $survey,
            $modelUtils,
            $viewTemplates,
            $surveyDetailView,
            $viewRowSelector,
            $rowView,
            $baseView,
            $viewUtils
            )->

  surveyApp = {}

  class SurveyFragmentApp extends $baseView
    className: "formbuilder-wrap container"
    features: {}
    events:
      "click .js-delete-row": "clickRemoveRow"
      "click #xlf-preview": "previewButtonClick"
      "click #csv-preview": "previewCsv"
      "click #xlf-download": "downloadButtonClick"
      "click #save": "saveButtonClick"
      "click #publish": "publishButtonClick"
      "click #settings": "toggleSurveyOptions"
      "update-sort": "updateSort"
    @create: (params = {}) ->
      if _.isString params.el
        params.el = $(params.el).get 0
      return new @(params)

    initialize: (options)->
      if options.survey and (options.survey instanceof $survey.Survey)
        @survey = options.survey
      else
        @survey = new $survey.Survey(options)

      @rowViews = new Backbone.Model()

      @ngScope = options.ngScope

      @survey.rows.on "add", @reset, @
      @survey.rows.on "remove", @reset, @
      @survey.on "row-detail-change", (row, key, val, ctxt)=>
        evtCode = "row-detail-change-#{key}"
        @$(".on-#{evtCode}").trigger(evtCode, row, key, val, ctxt)
      @$el.on "choice-list-update", (evt, clId) ->
        $(".on-choice-list-update[data-choice-list-cid='#{clId}']").trigger("rebuild-choice-list")

      @onPublish = options.publish || $.noop
      @onSave = options.save || $.noop
      @onPreview = options.preview || $.noop

      @expand_all_multioptions = null

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

    toggleSurveyOptions: ->
      if @features.surveySettings
        @$(".survey-header__options").toggle()

    render: ()->
      @$el.removeClass("content--centered").removeClass("content")
      @$el.html $viewTemplates.$$render('surveyApp', @survey)
      @survey.settings.on 'validated:invalid', (model, validations) ->
        for key, value of validations
            break

      @formEditorEl = @$(".-form-editor")
      @$(".survey-editor__null-top-row .expanding-spacer-between-rows .add-row-btn").click (evt)=>
        if !@emptySurveyXlfRowSelector
          @emptySurveyXlfRowSelector = new $viewRowSelector.RowSelector(el: @$el.find(".expanding-spacer-between-rows").get(0), survey: @survey, ngScope: @ngScope)
        @emptySurveyXlfRowSelector.expand()

      if @features.displayTitle
        $viewUtils.makeEditable @, @survey.settings, '.form-title', property:'form_title', options: validate: (value) ->
          if value.length > 255
            return "Length cannot exceed 255 characters, is " + value.length + " characters."
          return
      else
        @$(".survey-header__inner").hide()

      # see this page for info on what should be in a form_id
      # http://opendatakit.org/help/form-design/guidelines/
      $viewUtils.makeEditable @, @survey.settings, '.form-id', property:'form_id', transformFunction: $modelUtils.sluggify
      # @.survey.on 'change:form_id', _.bind viewUtils.handleChange('form_id', XLF.sluggify), @

      addOpts = @$("#additional-options")
      for detail in @survey.surveyDetails.models
        addOpts.append((new $surveyDetailView.SurveyDetailView(model: detail)).render().el)

      @reset()

      if not @features.surveySettings
        @$(".survey-header__options-toggle").hide()

      if @features.multipleQuestions
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
      else
        @$(".delete-row").hide()
        @$(".expanding-spacer-between-rows").hide()

      if not @features.copyToLibrary
        @$(".row-extras__add-to-question-library").hide()

      
      if @expand_all_multioptions is null
        $expand_multioptions = @$(".js-expand-multioptions--all")
        $expand_multioptions.click () =>
          if @expand_all_multioptions
            @expand_all_multioptions = false
            $(".card.card--selectquestion").removeClass("card--expandedchoices")
            $expand_multioptions.html($expand_multioptions.html().replace("Collapse", "Expand"));
          else
            @expand_all_multioptions = true
            $(".card.card--selectquestion").addClass("card--expandedchoices")
            $expand_multioptions.html($expand_multioptions.html().replace("Expand", "Collapse"));

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
        if !@features.skipLogic
          # TODO: avoid changing model from the view
          row.unset 'relevant'
        isEmpty = false
        unless (xlfrv = @rowViews.get(row.cid))
          if row.constructor.kls is 'Group'
            rv = new $rowView.GroupView(model: row, ngScope: @ngScope, surveyView: @)
          else
            rv = new $rowView.RowView(model: row, ngScope: @ngScope, surveyView: @)
          @rowViews.set(row.cid, rv)
          xlfrv = @rowViews.get(row.cid)

        $el = xlfrv.render().$el
        if $el.parents(@$el).length is 0
          @formEditorEl.append($el)

      @ngScope.displayQlib = false
      # @survey.forEachRow(fn, includeErrors: true)
      @survey.rows.each(fn, includeErrors: true)

      null_top_row = @formEditorEl.find(".survey-editor__null-top-row, .survey-editor__message").removeClass("expanded")
      if isEmpty
        null_top_row.removeClass("hidden")
      else
        null_top_row.addClass("hidden")
      # $viewUtils.reorderElemsByData(".xlf-row-view", @$el, "row-index")
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

        # this slideUp is for add/remove row animation
        rowEl.slideUp 175, "swing", ()=>
          @survey.rows.remove matchingRow

    onEscapeKeydown: -> #noop. to be overridden
    previewButtonClick: (evt)->
      if evt.shiftKey #and evt.altKey
        evt.preventDefault()
        $viewUtils.debugFrame @survey.toCSV()
        @onEscapeKeydown = $viewUtils.debugFrame.close
      else
        $viewUtils.enketoIframe.fromCsv @survey.toCSV(),
          previewServer: "http://kform.prod.kobotoolbox.org"
          onSuccess: => @onEscapeKeydown = $viewUtils.enketoIframe.close
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

  class surveyApp.SurveyApp extends SurveyFragmentApp
    features:
      multipleQuestions: true
      skipLogic: true
      displayTitle: true
      copyToLibrary: true
      surveySettings: true

  class surveyApp.QuestionApp extends SurveyFragmentApp
    features:
      multipleQuestions: false
      skipLogic: false
      displayTitle: false
      copyToLibrary: false
      surveySettings: false

  class surveyApp.SurveyTemplateApp extends $baseView
    events:
      "click .js-start-survey": "startSurvey"
    initialize: (@options)->
    render: ()->
      @$el.addClass("content--centered").addClass("content")
      @$el.html $viewTemplates.$$render('surveyTemplateApp')
      @
    startSurvey: ->
      new surveyApp.SurveyApp(@options).render()

  surveyApp
