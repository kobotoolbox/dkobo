define 'cs!xlform/view.row', [
        'backbone',
        'jquery',
        'cs!xlform/view.rowSelector',
        'cs!xlform/model.row',
        'cs!xlform/view.templates',
        'cs!xlform/view.utils',
        'cs!xlform/view.choices',
        'cs!xlform/view.rowDetail',
        ], (
            Backbone,
            $,
            $rowSelector,
            $row,
            $viewTemplates,
            $viewUtils,
            $viewChoices,
            $viewRowDetail,
            )->
  class BaseRowView extends Backbone.View
    tagName: "li"
    className: "survey__row  xlf-row-view xlf-row-view--depr"
    events:
     "drop": "drop"

    initialize: (opts)->
      @options = opts
      typeDetail = @model.get("type")
      @$el.attr("data-row-id", @model.cid)
      @ngScope = opts.ngScope
      @surveyView = @options.surveyView
      @model.on "detail-change", (key, value, ctxt)=>
        customEventName = "row-detail-change-#{key}"
        @$(".on-#{customEventName}").trigger(customEventName, key, value, ctxt)

    drop: (evt, index)->
      @$el.trigger("update-sort", [@model, index])

    getApp: ->
      @surveyView.getApp()

    # expandRowSelector: ->
    #   new $rowSelector.RowSelector(el: @$el.find(".survey__row__spacer").get(0), ngScope: @ngScope, spawnedFromView: @).expand()

    render: ->
      if @already_rendered
        return

      @already_rendered = true

      if @model instanceof $row.RowError
        @_renderError()
      else
        @_renderRow()
      @is_expanded = @$card.hasClass('card--expandedchoices')
      @
    _renderError: ->
      @$el.addClass("xlf-row-view-error")
      atts = $viewUtils.cleanStringify(@model.attributes)
      @$el.html $viewTemplates.$$render('row.rowErrorView', atts)
      @
    _renderRow: ->
      @$el.html $viewTemplates.$$render('row.xlfRowView')
      @$('.js-add-to-question-library').click @add_row_to_question_library
      @$('.js-clone-question').click @clone
      @$label = @$('.card__header-title')
      @$card = @$('.card')
      @$header = @$('.card__header')
      if 'getList' of @model and (cl = @model.getList())
        @$card.addClass('card--selectquestion card--expandedchoices')
        @is_expanded = true

        @listView = new $viewChoices.ListView(model: cl, rowView: @).render()

      @cardSettingsWrap = @$('.card__settings').eq(0)
      @defaultRowDetailParent = @cardSettingsWrap.find('.card__settings__fields--question-options').eq(0)
      @rowDetailViews = []
      for [key, val] in @model.attributesArray()
        view = new $viewRowDetail.DetailView(model: val, rowView: @)
        if key == 'label' and @model.get('type').get('value') == 'calculate'
          view.model = @model.get('calculation')
          @model.finalize()
          val.set('value', '')
        @rowDetailViews.push view
        view.render().insertInDOM(@)
        if key == 'label'
          @make_label_editable(view)

      @

    toggleSettings: (show)->
      if show is undefined
        show = !@_settingsExpanded

      if show and !@_settingsExpanded
        @_expandedRender()
        @$card.addClass('card--expanded-settings')
        @hideMultioptions?()
        @_settingsExpanded = true
      else if !show and @_settingsExpanded
        @$card.removeClass('card--expanded-settings')
        @_cleanupExpandedRender()
        @_settingsExpanded = false
      ``

    _cleanupExpandedRender: ->
      @$('.card__settings').remove()

    clone: (event) =>
      @model.getSurvey().insert_row @model, @model._parent.models.indexOf(@model) + 1

    add_row_to_question_library: (evt) =>
      evt.stopPropagation()
      @ngScope?.add_row_to_question_library @model

  class GroupView extends BaseRowView
    className: "survey__row survey__row--group  xlf-row-view xlf-row-view--depr"
    initialize: (opts)->
      @options = opts
      @_shrunk = !!opts.shrunk
      @$el.attr("data-row-id", @model.cid)
      @surveyView = @options.surveyView

    deleteGroup: (evt)=>
      skipConfirm = $(evt.currentTarget).hasClass('js-force-delete-group')
      if skipConfirm or confirm('Are you sure you want to split apart this group?')
        @_deleteGroup()
      evt.preventDefault()

    _deleteGroup: () =>
      @model.splitApart()
      @$el.remove()

    render: ->
      if !@already_rendered
        @$el.html $viewTemplates.row.groupView(@model)
        @$label = @$('.group__label').eq(0)
        @$rows = @$('.group__rows').eq(0)
        @$card = @$('.card')
        @$header = @$('.card__header,.group__header').eq(0)

      @model.rows.each (row)=>
        @getApp().ensureElInView(row, @, @$rows).render()

      if !@already_rendered
        # only render the row details which are necessary for the initial view (ie 'label')
        @make_label_editable new $viewRowDetail.DetailView(model: @model.get('label'), rowView: @).render().insertInDOM(@)



      @already_rendered = true
      @

    _expandedRender: ->
      @$header.after($viewTemplates.row.groupSettingsView())
      @cardSettingsWrap = @$('.card__settings').eq(0)
      @defaultRowDetailParent = @cardSettingsWrap.find('.card__settings__fields--active').eq(0)
      for [key, val] in @model.attributesArray() when key in ["name", "_isRepeat", "appearance", "relevant"]
        new $viewRowDetail.DetailView(model: val, rowView: @).render().insertInDOM(@)
    make_label_editable: (view) ->
      $viewUtils.makeEditable view, view.model, @$label, options:
        placement: 'right'
        rows: 3
      ,
      edit_callback: (value) ->
        value = value.replace(new RegExp(String.fromCharCode(160), 'g'), '')
        value = value.replace /\t/g, ''
        view.model.set 'value', value

        if value == ''
          return newValue: new Array(10).join('&nbsp;')
        else
        return newValue: value;

  class RowView extends BaseRowView
    _expandedRender: ->
      @$header.after($viewTemplates.row.rowSettingsView())
      @cardSettingsWrap = @$('.card__settings').eq(0)
      @defaultRowDetailParent = @cardSettingsWrap.find('.card__settings__fields--question-options').eq(0)

      for [key, val] in @model.attributesArray() when key isnt "label" and key isnt "type"
        new $viewRowDetail.DetailView(model: val, rowView: @).render().insertInDOM(@)
      @

    hideMultioptions: ->
      @$card.removeClass('card--expandedchoices')
      @is_expanded = false
    showMultioptions: ->
      @$card.addClass('card--expandedchoices')
      @$card.removeClass('card--expanded-settings')
      @toggleSettings(false)

    toggleMultioptions: ->
      if @is_expanded
        @hideMultioptions()
      else
        @showMultioptions()
        @is_expanded = true
      return
    make_label_editable: (view) ->
      $viewUtils.makeEditable view, view.model, @$label, options:
        placement: 'right'
        rows: 3
      ,
      transformFunction: (value) -> value

  RowView: RowView
  GroupView: GroupView
