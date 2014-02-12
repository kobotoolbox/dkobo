# class XlfRowView extends Backbone.View
# class XlfRowErrorView extends XlfRowView

class XLF.RowView extends Backbone.View
  tagName: "li"
  className: "xlf-row-view"
  events:
   "click .create-new-list": "createListForRow"
   "click .edit-list": "editListForRow"
   "click": "select"
   "click .add-row-btn": "expandRowSelector"
   "drop": "drop"
   "click .js-advanced-toggle": "expandCog"
  initialize: (opts)->
    @options = opts
    typeDetail = @model.get("type")
    @$el.attr("data-row-id", @model.cid)
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
    if !@xlfRowSelector
      @xlfRowSelector = new XLF.RowSelector(el: @$el.find(".expanding-spacer-between-rows").get(0), spawnedFromView: @)
    @xlfRowSelector.expand()
  render: ->
    @$el.html viewTemplates.xlfRowView()
    @$el.data("row-index", @model.getSurvey().rows.indexOf @model)
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

class XLF.RowErrorView extends Backbone.View
  tagName: "li"
  className: "xlf-row-view xlf-row-view-error card"
  render: ->
    atts = JSON.stringify(@model)
    @$el.data("row-index", @model.getSurvey().rows.indexOf @model)
    @$el.html """
      Row could not be displayed:<br>
      <pre>#{atts}</pre>
      <em>This question could not be imported. Please re-create it manually. Please contact us at info@kobotoolbox.org so we can fix this bug!</em>
    """
    @