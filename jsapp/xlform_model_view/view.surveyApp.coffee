define 'cs!xlform/view.surveyApp', [
        'underscore',
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
            _,
            Backbone,
            $survey,
            $modelUtils,
            $viewTemplates,
            $surveyDetailView,
            $viewRowSelector,
            $rowView,
            $baseView,
            $viewUtils,
            )->

  surveyApp = {}

  _notifyIfRowsOutOfOrder = do ->
    # a temporary function to notify devs if rows are mysteriously falling out of order
    fn = (surveyApp)->
      survey = surveyApp.survey
      elIds = []
      surveyApp.$('.survey__row').each -> elIds.push $(@).data('rowId')

      rIds = []
      gatherId = (r)->
        rIds.push(r.cid)
        if 'forEachRow' of r
          r.forEachRow(gatherId, flat: true, includeGroups: true)
      survey.forEachRow(gatherId, flat: true, includeGroups: true)

      _s = (i)-> JSON.stringify(i)
      if _s(rIds) isnt _s(elIds)
        console?.error "Order do not match"
        console?.error _s(rIds)
        console?.error _s(elIds)
        false
      else
        true
    _.debounce(fn, 2500)


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
      "click #settings": "toggleSurveySettings"
      "update-sort": "updateSort"
      "click .js-select-row": "selectRow"
      "click .js-select-row--force": "forceSelectRow"
      "click .js-group-rows": "groupSelectedRows"
      "click .js-toggle-group-settings": "toggleGroupSettings"
      "click .js-toggle-group-expansion": "toggleGroupExpansion"
      "click .js-toggle-row-settings": "toggleRowSettings"
      "click .js-toggle-row-multioptions": "toggleRowMultioptions"
      "click .js-expand-row-selector": "expandRowSelector"
      "click .rowselector_toggle-library": "toggleLibrary"
      "click .card__settings__tabs li": "switchTab"
      "mouseenter .card__buttons__button": "buttonHoverIn"
      "mouseleave .card__buttons__button": "buttonHoverOut"
    @create: (params = {}) ->
      if _.isString params.el
        params.el = $(params.el).get 0
      return new @(params)

    switchTab: (event) ->
      $et = $(event.currentTarget)
      if $et.hasClass("heading")
        event.preventDefault()
        return

      tabId = $et.data('cardSettingsTabId')

      $et.parent('ul').find('.card__settings__tabs__tab--active').removeClass('card__settings__tabs__tab--active')
      $et.addClass('card__settings__tabs__tab--active')

      $et.parents('.card__settings').find(".card__settings__fields--active").removeClass('card__settings__fields--active')
      $et.parents('.card__settings').find(".card__settings__fields--#{tabId}").addClass('card__settings__fields--active')

    surveyRowSortableStop: (evt)->
      $et = $(evt.target)
      cid = $et.data('rowId')

      survey_findRowByCid = (cid)=>
        if cid
          @survey.findRowByCid(cid, includeGroups: true)

      row = survey_findRowByCid(cid)
      [_prev, _par] = @_getRelatedElIds($et)
      @survey._insertRowInPlace row,
        previous: survey_findRowByCid _prev
        parent: survey_findRowByCid _par
        event: 'sort'
      return

    _getRelatedElIds: ($el)->
      prev = $el.prev('.survey__row').eq(0).data('rowId')
      parent = $el.parents('.survey__row').eq(0).data('rowId')
      [prev, parent]

    initialize: (options)->
      if options.survey and (options.survey instanceof $survey.Survey)
        @survey = options.survey
      else
        @survey = new $survey.Survey(options)

      @__rowViews = new Backbone.Model()
      @ngScope = options.ngScope

      @survey.on 'rows-add', @reset, @
      @survey.on 'rows-remove', @reset, @
      @survey.on "row-detail-change", (row, key, val, ctxt)=>
        evtCode = "row-detail-change-#{key}"
        @$(".on-#{evtCode}").trigger(evtCode, row, key, val, ctxt)
      @$el.on "choice-list-update", (evt, clId) ->
        $(".on-choice-list-update[data-choice-list-cid='#{clId}']").trigger("rebuild-choice-list")

      @$el.on "survey__row-sortablestop", _.bind @surveyRowSortableStop, @

      @onPublish = options.publish || $.noop
      @onSave = options.save || $.noop
      @onPreview = options.preview || $.noop

      @expand_all_multioptions = null

      $(window).on "keydown", (evt)=>
        @onEscapeKeydown(evt)  if evt.keyCode is 27

    registerView: (cid, view)->
      @__rowViews.set(cid, view)

    getView: (cid)->
      @__rowViews.get(cid)

    updateSort: (evt, model, position)->
      # inspired by this:
      # http://stackoverflow.com/questions/10147969/saving-jquery-ui-sortables-order-to-backbone-js-collection
      @survey.rows.remove(model)
      @survey.rows.each (m, index)->
        m.ordinal = if index >= position then (index + 1) else index
      model.ordinal = position
      @survey.rows.add(model, at: position)
      return

    forceSelectRow: (evt)->
      # forceSelectRow is used to mock the multiple-select key
      @selectRow($.extend({}, evt))
    selectRow: (evt)->
      $et = $(evt.target)
      $ect = $(evt.currentTarget)
      # a way to ensure the event is not run twice when in nested .js-select-row elements
      _isIntendedTarget = $ect.closest('.survey__row').get(0) is $et.closest('.survey__row').get(0)
      if _isIntendedTarget
        if !evt.ctrlKey
          selected_rows = @selectedRows()
          target = $et.closest('.survey__row')
          if !target.hasClass('survey__row--selected') || selected_rows.length > 1
            $('.survey__row').removeClass('survey__row--selected')


        $et.closest('.survey__row').toggleClass("survey__row--selected")

        @questionSelect()

    questionSelect: (evt)->
      @activateGroupButton(@selectedRows().length > 0)
      return

    activateGroupButton: (active=true)->
      @$('.btn--group-questions').toggleClass('btn--disabled', !active)

    getApp: -> @

    toggleSurveySettings: (evt) ->
      $et = $(evt.currentTarget)
      $et.toggleClass('active__settings')
      if @features.surveySettings
        @$(".form__settings").toggle()

    toggleGroupSettings: (evt)->
      $et = $(evt.currentTarget)
      $group = $et.closest('.group').toggleClass('group--expanded-settings')
    toggleGroupExpansion: (evt)->
      $et = $(evt.currentTarget)
      $group = $et.closest('.group').toggleClass('group--shrunk')

    toggleRowSettings: (evt)->
      $et = $(evt.currentTarget)
      $row = $et.closest('.card')
      $row.removeClass('card--expandedchoices')
      $row.toggleClass('card--expandedsettings')
    toggleRowMultioptions: (evt)->
      $et = $(evt.currentTarget)
      $row = $et.closest('.card')
      $row.removeClass('card--expandedsettings')
      $row.toggleClass('card--expandedchoices')

    expandRowSelector: (evt)->
      $ect = $(evt.currentTarget)
      if $ect.parents('.survey-editor__null-top-row').length > 0
        # This is the initial row in the survey
        new $viewRowSelector.RowSelector(el: @$el.find(".survey__row__spacer").get(0), survey: @survey, ngScope: @ngScope, surveyView: @, reversible:true).expand()
      else
        $row = $ect.parents('.survey__row').eq(0)
        $spacer = $ect.parents('.survey__row__spacer')
        rowId = $row.data('rowId')
        view = @getViewForRow(cid: rowId)
        if !view
          # hopefully, this error is never triggered
          throw new Error('View for row was not found: ' + rowId)
        new $viewRowSelector.RowSelector(el: $spacer.get(0), ngScope: @ngScope, spawnedFromView: view, surveyView: @, reversible:true).expand()

    render: ()->
      @$el.removeClass("content--centered").removeClass("content")
      @$el.html $viewTemplates.$$render('surveyApp', @)
      @survey.settings.on 'validated:invalid', (model, validations) ->
        for key, value of validations
            break

      @formEditorEl = @$(".-form-editor")
      # @$(".survey-editor__null-top-row .survey__row__spacer .btn--addrow").click (evt)=>
      #   if !@emptySurveyXlfRowSelector
      #     @emptySurveyXlfRowSelector = new $viewRowSelector.RowSelector(el: @$el.find(".survey__row__spacer").get(0), survey: @survey, ngScope: @ngScope)
      #   @emptySurveyXlfRowSelector.expand()

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
        @activateSortable()
      else
        @$el.addClass('survey-editor--singlequestion')

        if @survey.rows.length is 0
          new $viewRowSelector.RowSelector(el: @$el.find(".survey__row__spacer").get(0), survey: @survey, ngScope: @ngScope, surveyView: @, reversible: false).expand()

      if not @features.copyToLibrary
        # TODO: what happened to this element?
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

    getItemPosition: (item) ->
      i = 0
      while item.length > 0
        item = item.prev()
        i++

      return i
    activateSortable: ->
      $el = @formEditorEl
      survey = @survey

      sortable_activate_deactivate = (evt, ui)->
        isActivateEvt = evt.type is 'sortactivate'
        ui.item.toggleClass 'sortable-active', isActivateEvt
        $el.toggleClass 'insort', isActivateEvt

      sortable_stop = (evt, ui)=>
        $(ui.item).trigger('survey__row-sortablestop')

      @formEditorEl.sortable({
          # PM: commented out axis, because it's better if cards move horizontally and vertically
          # axis: "y"
          cancel: "button, .btn--addrow, .well, ul.list-view, li.editor-message, .editableform, .row-extras, .js-cancel-sort"
          cursor: "move"
          distance: 5
          items: "> li"
          placeholder: "placeholder"
          connectWith: ".group__rows"
          opacity: 0.9
          scroll: true
          stop: sortable_stop
          activate: sortable_activate_deactivate
          deactivate: sortable_activate_deactivate
          receive: (evt, ui) =>
            if ui.sender.hasClass('group__rows')
              return
            item = ui.item.prev()

            @ngScope.add_item @getItemPosition(item)
            ui.sender.sortable('cancel')
        })
      group_rows = @formEditorEl.find('.group__rows')
      group_rows.off 'mouseenter', '> .survey__row', @_preventSortableIfGroupTooSmall
      group_rows.off 'mouseleave', '> .survey__row', @_preventSortableIfGroupTooSmall
      group_rows.on 'mouseenter', '> .survey__row', @_preventSortableIfGroupTooSmall
      group_rows.on 'mouseleave', '> .survey__row', @_preventSortableIfGroupTooSmall
      group_rows.sortable({
          axis: "y"
          cancel: '.js-cancel-sort, .js-cancel-group-sort'
          cursor: "move"
          distance: 5
          items: "> li"
          placeholder: "placeholder"
          connectWith: ".group__rows, .survey-editor__list"
          opacity: 0.9
          scroll: true
          stop: sortable_stop
          activate: sortable_activate_deactivate
          deactivate: sortable_activate_deactivate
        })
      return
    _preventSortableIfGroupTooSmall: (evt)->
      $ect = $(evt.currentTarget)
      if $ect.siblings('.survey__row').length is 0
        if evt.type is 'mouseenter'
          $ect.addClass('js-cancel-group-sort')
        else
          $ect.removeClass('js-cancel-group-sort')

    validateSurvey: ()->
      true

    previewCsv: ->
      scsv = @survey.toCSV()
      console?.clear()
      log scsv
      return

    ensureElInView: (row, parentView, $parentEl)->
      view = @getViewForRow(row)
      $el = view.$el
      index = row._parent.indexOf(row)

      if index > 0
        prevRow = row._parent.at(index - 1)
      if prevRow
        prevRowEl = $parentEl.find(".survey__row[data-row-id=#{prevRow.cid}]")

      requiresInsertion = false
      detachRowEl = (detach)->
        if detach
          $el.detach()
        requiresInsertion = true

      # trying to avoid unnecessary reordering of DOM (very slow)
      if $el.parents($parentEl).length is 0
        detachRowEl()
      else if $el.parent().get(0) isnt $parentEl.get(0)
        # element does not have the correct parent
        detachRowEl()
      else if !prevRow
        if $el.prev('.survey__row').not('.survey__row--deleted').data('rowId')
          detachRowEl()
      else if $el.prev('.survey__row').not('.survey__row--deleted').data('rowId') isnt prevRow.cid
        # element is in the wrong location
        detachRowEl()

      if requiresInsertion
        if prevRow
          $el.insertAfter(prevRowEl)
        else
          $el.prependTo($parentEl)

      view

    getViewForRow: (row)->
      unless (xlfrv = @__rowViews.get(row.cid))
        if row.constructor.kls is 'Group'
          rv = new $rowView.GroupView(model: row, ngScope: @ngScope, surveyView: @)
        else
          rv = new $rowView.RowView(model: row, ngScope: @ngScope, surveyView: @)
        @__rowViews.set(row.cid, rv)
        xlfrv = @__rowViews.get(row.cid)
      xlfrv

    reset: ->
      _notifyIfRowsOutOfOrder(@)
      fe = @formEditorEl
      isEmpty = true
      fn = (row)=>
        if !@features.skipLogic
          # TODO: avoid changing model from the view
          row.unset 'relevant'
        isEmpty = false
        @ensureElInView(row, @, @formEditorEl).render()

      @survey.forEachRow(fn, includeErrors: true, includeGroups: true, flat: true)

      null_top_row = @formEditorEl.find(".survey-editor__null-top-row, .survey-editor__message").removeClass("expanded")
      if isEmpty
        null_top_row.removeClass("hidden")
      else
        null_top_row.addClass("hidden")

      if @features.multipleQuestions
        @activateSortable()

      # $viewUtils.reorderElemsByData(".xlf-row-view", @$el, "row-index")
      return

    clickRemoveRow: (evt)->
      evt.preventDefault()
      if confirm("Are you sure you want to delete this question? This action cannot be undone.")
        $et = $(evt.target)
        rowEl = $et.parents(".survey__row").eq(0)
        rowId = rowEl.data("rowId")

        matchingRow = false
        findMatch = (r)->
          if r.cid is rowId
            matchingRow = r
          return

        @survey.forEachRow findMatch, {
          includeGroups: false
        }

        if !matchingRow
          throw new Error("Matching row was not found.")

        matchingRow.detach()
        # this slideUp is for add/remove row animation
        rowEl.addClass('survey__row--deleted')
        rowEl.slideUp 175, "swing", ()=>
          rowEl.remove()
          @survey.rows.remove matchingRow

    groupSelectedRows: ->
      rows = @selectedRows()
      $q = @$('.survey__row--selected')
      $q.remove()
      $q.removeClass('survey__row--selected')
      @activateGroupButton(false)
      if rows.length > 0
        @survey._addGroup(__rows: rows)
        @reset()
        true
      else
        false

    selectedRows: ()->
      rows = []
      @$el.find('.survey__row--selected').each (i, el)=>
        $el = $(el)
        rowId = $el.data("rowId")
        matchingRow = false
        findMatch = (row)->
          if row.cid is rowId
            matchingRow = row
        @survey.forEachRow findMatch, includeGroups: true
        # matchingRow = @survey.rows.find (row)-> row.cid is rowId
        rows.push matchingRow
      rows

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
      return

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
    toggleLibrary: (evt)->
      evt.stopPropagation()
      $et = $(evt.target)
      $et.toggleClass('active__sidebar')
      $("section.form-builder").toggleClass('active__sidebar')
      @ngScope.displayQlib = !@ngScope.displayQlib
      @ngScope.$apply()

      $("section.koboform__questionlibrary").toggleClass('active').data("rowIndex", -1)
      return
    buttonHoverIn: (evt)->
      evt.stopPropagation()
      $et = $(evt.target)
      if $et.is('i')
        $et = $(evt.target).parent()

      bColor = $et.data('buttonColor')
      bText = $et.data('buttonText')
      $et.parents('.card__buttons').addClass('noborder')
      $et.parents('.card__header').append('<div class="bg">')
      $et.parents('.card__header').find('.bg').addClass("#{bColor}").html("<span>#{bText}</span>")
      return
    buttonHoverOut: (evt)->
      evt.stopPropagation()
      $et = $(evt.target)
      $et.parents('.card__buttons').removeClass('noborder')
      $et.parents('.card__header').find('.bg').remove()
      return

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
