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
      "click .js-delete-group": "clickDeleteGroup"
      "click .js-add-to-question-library": "clickAddRowToQuestionLibrary"
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
      "click .js-toggle-card-settings": "toggleCardSettings"
      "click .js-toggle-group-expansion": "toggleGroupExpansion"
      "click .js-toggle-row-multioptions": "toggleRowMultioptions"
      "click .js-expand-row-selector": "expandRowSelector"
      "click .js-expand-multioptions--all": "expandMultioptions"
      "click .rowselector_toggle-library": "toggleLibrary"
      "mouseenter .card__buttons__button": "buttonHoverIn"
      "mouseleave .card__buttons__button": "buttonHoverOut"
      "click .card__settings__tabs li": "switchTab"

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
      @reset = ()=>
        clearTimeout(@_timedReset)  if @_timedReset
        @_timedReset = setTimeout _.bind(@_reset, @), 0

      if options.survey and (options.survey instanceof $survey.Survey)
        @survey = options.survey
      else
        @survey = new $survey.Survey(options)

      @__rowViews = new Backbone.Model()
      @ngScope = options.ngScope

      $(document).on 'click', @deselect_rows

      @survey.settings.on 'change:form_id', (model, value) =>
        $('.form-id').text(value)
      @survey.on 'rows-add', @reset, @
      @survey.on 'rows-remove', @reset, @
      @survey.on "row-detail-change", (row, key, val, ctxt)=>
        evtCode = "row-detail-change-#{key}"
        @$(".on-#{evtCode}").trigger(evtCode, row, key, val, ctxt)
      @$el.on "choice-list-update", (evt, clId) =>
        $(".on-choice-list-update[data-choice-list-cid='#{clId}']").trigger("rebuild-choice-list")
        @survey.trigger 'choice-list-update'

      @$el.on "survey__row-sortablestop", _.bind @surveyRowSortableStop, @

      @onPublish = options.publish || $.noop
      @onSave = options.save || $.noop
      @onPreview = options.preview || $.noop

      @expand_all_multioptions = () -> @$('.survey__row:not(.survey__row--deleted) .card--expandedchoices:visible').length > 0

      $(window).on "keydown", (evt)=>
        @onEscapeKeydown(evt)  if evt.keyCode is 27

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
    deselect_all_rows: () ->
      @$('.survey__row').removeClass('survey__row--selected')

    deselect_rows: (evt) =>
      if @is_selecting
        @is_selecting = false
      else
        @deselect_all_rows()
      return
    selectRow: (evt)->
      @is_selecting = true
      $et = $(evt.target)
      if $et.hasClass('js-blur-on-select-row') || $et.hasClass('editable-wrapper')
        return
      $ect = $(evt.currentTarget)
      if $et.closest('.card__settings, .card__buttons, .group__header__buttons, .js-cancel-select-row').length > 0
        return
      # a way to ensure the event is not run twice when in nested .js-select-row elements
      _isIntendedTarget = $ect.closest('.survey__row').get(0) is $et.closest('.survey__row').get(0)
      if _isIntendedTarget
        $target = $et.closest('.survey__row')
        if !(evt.ctrlKey || evt.metaKey)
          selected_rows = $target.siblings('.survey__row--selected')
          if !$target.hasClass('survey__row--selected') || selected_rows.length > 1
            @deselect_all_rows()



        $target.toggleClass("survey__row--selected")
        if $target.hasClass('survey__row--group')
          $target.find('li.survey__row, li.survey__row--group').toggleClass("survey__row--selected", $target.hasClass("survey__row--selected"))

        $group = $target.parent().closest('.survey__row')
        if $group.length > 0
          @select_group_if_all_items_selected($group)

        @questionSelect()
        @$('.js-blur-on-select-row').blur()
      return

    select_group_if_all_items_selected: ($group) ->
      $rows = $group.find('.survey__row')
      $group.toggleClass('survey__row--selected', $rows.length == $rows.filter('.survey__row--selected').length)
      $group = $group.parent().closest('.survey__row')
      if $group.length > 0
        @select_group_if_all_items_selected($group)

    questionSelect: (evt)->
      @activateGroupButton(@$el.find('.survey__row--selected').length > 0)
      return

    activateGroupButton: (active=true)->
      @$('.btn--group-questions').toggleClass('btn--disabled', !active)

    getApp: -> @

    toggleSurveySettings: (evt) ->
      $et = $(evt.currentTarget)
      $et.toggleClass('active__settings')
      if @features.surveySettings
        $settings = @$(".form__settings")
        $settings.toggle()
        close_settings = (e) ->
          $settings_toggle = $('#settings')

          is_in_settings = (element) ->
            element == $settings[0] || $settings.find(element).length > 0
          is_in_settings_toggle = (element) ->
            element == $settings_toggle[0] || $settings_toggle.find(element).length > 0

          if !(is_in_settings(e.target) || is_in_settings_toggle(e.target))
            $settings.hide()
            $et.removeClass('active__settings')
            $('body').off 'click', close_settings

        $('body').on 'click', close_settings


    _getViewForTarget: (evt)->
      $et = $(evt.currentTarget)
      modelId = $et.closest('.survey__row').data('row-id')
      view = @__rowViews.get(modelId)
      throw new Error("view is not found for target element")  unless view
      view

    toggleCardSettings: (evt)->
      @_getViewForTarget(evt).toggleSettings()
    
    toggleGroupExpansion: (evt)->
      view = @_getViewForTarget(evt)
      view.$el.toggleClass('group--shrunk')

    toggleRowMultioptions: (evt)->
      view = @_getViewForTarget(evt)
      view.toggleMultioptions()
      @set_multioptions_label()

    expandRowSelector: (evt)->
      $ect = $(evt.currentTarget)
      if $ect.parents('.survey-editor__null-top-row').length > 0
        # This is the initial row in the survey
        @null_top_row_view_selector.expand()
      else
        $row = $ect.parents('.survey__row').eq(0)
        $spacer = $ect.parents('.survey__row__spacer')
        rowId = $row.data('rowId')
        view = @getViewForRow(cid: rowId)
        if !view
          # hopefully, this error is never triggered
          throw new Error('View for row was not found: ' + rowId)

        new $viewRowSelector.RowSelector(el: $spacer.get(0), ngScope: @ngScope, spawnedFromView: view, surveyView: @, reversible:true, survey: @survey).expand()

    _render_html: ->
      @$el.html $viewTemplates.$$render('surveyApp', @)
      @formEditorEl = @$(".-form-editor")
      @settingsBox = @$(".form__settings-meta__questions")

    _render_attachEvents: ->
      @survey.settings.on 'validated:invalid', (model, validations) ->
        for key, value of validations
            break

      if @features.displayTitle
        $viewUtils.makeEditable @, @survey.settings, '.form-title', property:'form_title', options: validate: (value) ->
          if value.length > 255
            return "Length cannot exceed 255 characters, is " + value.length + " characters."
          return

      if @features.surveySettings
        $viewUtils.makeEditable @, @survey.settings, '.form-id', property:'form_id', transformFunction: $modelUtils.sluggify


    _render_addSubViews: ->
      meta_view = new $viewUtils.ViewComposer()

      for detail in @survey.surveyDetails.models
        if detail.get('name') in ["start", "end", "today", "deviceid"]
          meta_view.add new $surveyDetailView.SurveyDetailView(model: detail, selector: '.settings__first-meta')
        else
          meta_view.add new $surveyDetailView.SurveyDetailView(model: detail, selector: '.settings__second-meta')

      meta_view.render()
      meta_view.attach_to @settingsBox

      # in which cases is the null_top_row_view_selector viewed
      @null_top_row_view_selector = new $viewRowSelector.RowSelector(el: @$el.find(".survey__row__spacer").get(0), survey: @survey, ngScope: @ngScope, surveyView: @, reversible:true)

    _render_hideConditionallyDisplayedContent: ->
      if not @features.displayTitle
        @$(".survey-header__inner").hide()

      if not @features.surveySettings
        @$(".survey-header__options-toggle").hide()

      if !@features.multipleQuestions
        @$el.addClass('survey-editor--singlequestion')
        @$el.find(".survey-editor__null-top-row").addClass("survey-editor__null-top-row--hidden")
        if @survey.rows.length is 0
          @null_top_row_view_selector.expand()

      if !@features.copyToLibrary
        @$el.find('.js-add-to-question-library').hide()

    render: ()->
      @$el.addClass("survey-editor--loading")
      @$el.removeClass("content--centered").removeClass("content")

      try
        @_render_html()
        @_render_attachEvents()
        @_render_addSubViews()
        @_reset()

        @_render_hideConditionallyDisplayedContent()

      catch error
        @$el.addClass("survey-editor--error")
        throw error

      @$el.removeClass("survey-editor--loading")
      @

    set_multioptions_label: () ->
      $expand_multioptions = @$(".js-expand-multioptions--all")
      if @expand_all_multioptions()
        $expand_multioptions.html($expand_multioptions.html().replace("Show", "Hide"));
        icon = $expand_multioptions.find('i')
        icon.removeClass('fa-caret-right')
        icon.addClass('fa-caret-down')
      else
        $expand_multioptions.html($expand_multioptions.html().replace("Hide", "Show"));
        icon = $expand_multioptions.find('i')
        icon.removeClass('fa-caret-down')
        icon.addClass('fa-caret-right')
    expandMultioptions: ->
      $expand_multioptions = @$(".js-expand-multioptions--all")
      if @expand_all_multioptions()
        @$(".card--expandedchoices").each (i, el)=>
          @_getViewForTarget(currentTarget: el).hideMultioptions()
      else
        @$(".card--selectquestion").each (i, el)=>               
          @_getViewForTarget(currentTarget: el).showMultioptions()

      @set_multioptions_label()
      return

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
      group_rows.each (index) ->
        $(@).sortable({
          cancel: 'button, .btn--addrow, .well, ul.list-view, li.editor-message, .editableform, .row-extras, .js-cancel-sort, .js-cancel-group-sort' + index
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
        $(@).attr('data-sortable-index', index)

      group_rows.find('.survey__row').each @_preventSortableIfGroupTooSmall

      return
    _preventSortableIfGroupTooSmall: (index, element)->
      $element = $(element)
      class_name_matches = element.className.match(/js-cancel-group-sort\d+/g)
      if class_name_matches?
        $element.removeClass class_name_matches.join(' ')
      if $element.siblings('.survey__row').length is 0
        $element.addClass('js-cancel-group-sort' + ($element.closest('.group__rows').attr('data-sortable-index')))

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
          $el.appendTo($parentEl)

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

    _reset: ->
      _notifyIfRowsOutOfOrder(@)

      isEmpty = true
      @survey.forEachRow(((row)=>
          if !@features.skipLogic
            row.unset 'relevant'
          isEmpty = false
          @ensureElInView(row, @, @formEditorEl).render()
        ), includeErrors: true, includeGroups: true, flat: true)

      @set_multioptions_label()

      null_top_row = @formEditorEl.find(".survey-editor__null-top-row").removeClass("expanded")
      null_top_row.toggleClass("survey-editor__null-top-row--hidden", !isEmpty)

      
      if @features.multipleQuestions
        @activateSortable()

      return

    clickDeleteGroup: (evt)->
      @_getViewForTarget(evt).deleteGroup(evt)

    clickAddRowToQuestionLibrary: (evt)->
      @_getViewForTarget(evt).add_row_to_question_library(evt)

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

        parent = matchingRow._parent._parent
        matchingRow.detach()
        # this slideUp is for add/remove row animation
        rowEl.addClass('survey__row--deleted')
        rowEl.slideUp 175, "swing", ()=>
          rowEl.remove()
          @survey.rows.remove matchingRow
          if parent != @ && parent.rows.length == 0
            parent_view = @__rowViews.get(parent.cid)._deleteGroup()
        @set_multioptions_label()

    groupSelectedRows: ->
      rows = @selectedRows()
      $q = @$('.survey__row--selected')
      $q.detach()
      $q.removeClass('survey__row--selected')
      @activateGroupButton(false)
      if rows.length > 0
        @survey._addGroup(__rows: rows)
        @reset()
        @$('.js-group-rows').blur()
        true
      else
        false

    selectedRows: ()->
      rows = []
      @$el.find('.survey__row--selected').each (i, el)=>
        $el = $(el)
        if $el.parents('li.survey__row--group.survey__row--selected').length > 0
          return
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
          previewServer: window.koboConfigs?.previewServer or "http://kf.kobotoolbox.org"
          enketoServer: window.koboConfigs?.enketoServer or false
          enketoPreviewUri: window.koboConfigs?.enketoPreviewUri or false
          onSuccess: => @onEscapeKeydown = $viewUtils.enketoIframe.close
          onError: (message, opts)=> @alert message, opts
      return

    alert: (message, opts={}) ->
      title = opts.title or 'Error'
      $('.alert-modal').html(message).dialog('option', {
        title: title,
        width: 500,
        dialogClass: 'surveyapp__alert'
      }).dialog 'open'
    downloadButtonClick: (evt)->
      # Download = save a CSV file to the disk
      surveyCsv = @survey.toCSV()
      if surveyCsv
        evt.target.href = "data:text/csv;charset=utf-8,#{encodeURIComponent(@survey.toCSV())}"
    saveButtonClick: (evt)->
      # Save = store CSV in local storage.
      icon = $(evt.currentTarget).find('i')
      icon.addClass 'fa-spinner fa-spin blue'
      icon.removeClass 'fa-check-circle green'
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
