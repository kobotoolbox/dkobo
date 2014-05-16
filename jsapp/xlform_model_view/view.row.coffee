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
    className: "xlf-row-view"
    events:
     "click": "select"
     "click .js-expand-row-selector": "expandRowSelector"
     "drop": "drop"
     "click .js-advanced-toggle": "toggleSettings"
     "click .js-expand-multioptions": "toggleMultiOptions"
     "click .row-extras__add-to-question-library": "add_row_to_question_library"

    initialize: (opts)->
      @options = opts
      typeDetail = @model.get("type")
      @$el.attr("data-row-id", @model.cid)
      @ngScope = opts.ngScope
      # @model.on "change", @render, @
      # typeDetail.on "change:value", _.bind(@render, @)
      # typeDetail.on "change:listName", _.bind(@render, @)
      @surveyView = @options.surveyView
      @model.on "detail-change", (key, value, ctxt)=>
        customEventName = "row-detail-change-#{key}"
        @$(".on-#{customEventName}").trigger(customEventName, key, value, ctxt)

      @$el.on "xlf-blur", =>
        @$el.removeClass("xlf-selected")

    drop: (evt, index)->
      @$el.trigger("update-sort", [@model, index])

    select: ->
      unless @$el.hasClass("xlf-selected")
        $(".xlf-selected").trigger("xlf-blur")
        @$el.addClass("xlf-selected")
    expandRowSelector: ->
      new $rowSelector.RowSelector(el: @$el.find(".expanding-spacer-between-rows").get(0), ngScope: @ngScope, spawnedFromView: @).expand()

    render: ->
      if @model instanceof $row.RowError
        @_renderError()
      else
        @_renderRow()
      @$el.data("row-index", @model.getSurvey().rows.indexOf @model)
      @
    _renderError: ->
      @$el.addClass("xlf-row-view-error")
      atts = $viewUtils.cleanStringify(@model.attributes)
      @$el.html $viewTemplates.$$render('row.rowErrorView', atts)
      @
    _renderRow: ->
      @$el.html $viewTemplates.$$render('row.xlfRowView')
      @$card = @$el.find('.card')
      if (cl = @model.getList())
        @$card.addClass('card--selectquestion')
        @listView = new $viewChoices.ListView(model: cl, rowView: @).render()

      # @multiOptions = @$(".row__multioptions")
      # @multiOptions.addClass("hidden")

      @rowExtras = @$(".row-extras")
      @rowExtrasSummary = @$(".row-extras-summary")
      for [key, val] in @model.attributesArray()
        new $viewRowDetail.DetailView(model: val, rowView: @).renderInRowView(@)
      @

    toggleSettings: (evt)->
      evt.stopPropagation()
      # cannot be expandsettings and expandchoices at the same time
      @$card.removeClass('card--expandedchoices')
      @$card.toggleClass('card--expandsettings')
      @$(evt.currentTarget).toggleClass("activated")

    toggleMultiOptions: (evt)->
      evt.stopPropagation()
      # cannot be expandsettings and expandchoices at the same time
      @$card.removeClass('card--expandsettings')
      @$card.toggleClass('card--expandedchoices')

    add_row_to_question_library: (evt) ->
      evt.stopPropagation()
      @ngScope.add_row_to_question_library @model

  class GroupView extends BaseRowView
    initialize: (opts)->
      @options = opts
    render: ->
      @$el.html $viewTemplates.row.groupView(@model)
      @$rows = @$('.group__rows')
      @model.rows.each (row)=>
        new RowView(model: row, ngScope: @ngScope, surveyView: @).render().$el.appendTo(@$rows)
      @$el.data("row-index", @model.getSurvey().rows.indexOf @model)
      @

  class RowView extends BaseRowView

  RowView: RowView
  GroupView: GroupView
