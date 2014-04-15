class XLF.RowView extends Backbone.View
  tagName: "li"
  className: "xlf-row-view"
  events:
   "click .create-new-list": "createListForRow"
   "click .edit-list": "editListForRow"
   "click": "select"
   "click .js-expand-row-selector": "expandRowSelector"
   "drop": "drop"
   "click .js-advanced-toggle": "expandCog"
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
    new XLF.RowSelector(el: @$el.find(".expanding-spacer-between-rows").get(0), ngScope: @ngScope, spawnedFromView: @).expand()
  render: ->
    if @model instanceof XLF.RowError
      @_renderError()
    else
      @_renderRow()
    @$el.data("row-index", @model.getSurvey().rows.indexOf @model)
    @
  _renderError: ->
    @$el.addClass("xlf-row-view-error")
    atts = viewUtils.cleanStringify(@model.attributes)
    @$el.html viewTemplates.rowErrorView(atts)
    @
  _renderRow: ->
    @$el.html viewTemplates.xlfRowView()
    unless (cl = @model.getList())
      cl = new XLF.ChoiceList()
      @model.setList(cl)
    @listView = new XLF.ListView(el: @$(".list-view"), model: cl, rowView: @).render()
    @rowExtras = @$(".row-extras")
    @rowExtrasSummary = @$(".row-extras-summary")
    for [key, val] in @model.attributesArray()
      new XLF.DetailView(model: val, rowView: @).renderInRowView(@)
    @
  editListForRow: (evt)->
    @_ensureNoListViewsOpen()
    $et = $(evt.target)
    survey = @model._parent
    list = @model.getList()
    @_displayEditListView($et, survey, list)

  createListForRow: (evt)->
    @_ensureNoListViewsOpen()
    $et = $(evt.target)
    survey = @model._parent
    list = new XLF.ChoiceList()
    @_displayEditListView($et, survey, list)

  _ensureNoListViewsOpen: ->
    # this is a temporary solution which aims to prevent simultaneous list-view edit boxes
    throw new Error("ListView open")  if $(".edit-list-view").length > 0

  _displayEditListView: ($et, survey, list)->
    lv = new XLF.EditListView(choiceList: list, survey: survey, rowView: @)
    # the .detail-view element has a left margin of 20px
    padding = 6
    parentElMarginLeft = 20
    clAnchor = $et.parent().find(".choice-list-anchor")
    parentWrap = clAnchor.parent()
    leftMargin = clAnchor.eq(0).position().left - (padding + parentElMarginLeft)
    $lvel = lv.render().$el.css "margin-left", leftMargin
    parentWrap.append $lvel.hide()
    $lvel.slideDown 175

  newListView: (rv)->
    lv = new XLF.EditListView(choiceList: new XLF.ChoiceList(), survey: @model._parent, rowView: @)
    $lvel = lv.render().$el.css @$(".select-list").position()
    @$el.append $lvel
  expandCog: (evt)->
    evt.stopPropagation()
    @rowExtras.parent().toggleClass("activated")
    @rowExtrasSummary.toggleClass("hidden")
    @rowExtras.toggleClass("hidden")
  add_row_to_question_library: (evt) ->
    evt.stopPropagation()
    @ngScope.add_row_to_question_library @model