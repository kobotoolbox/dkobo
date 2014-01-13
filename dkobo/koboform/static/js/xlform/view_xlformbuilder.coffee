###
This file provides the "SurveyApp" object which is an extension of
Backbone.View and builds the XL(S)Form Editor in the browser.
###

class XlformError extends Error
  constructor: (@message)->
    @name = "XlformError"

# $().editInPlace seems to depend on $.browser
# Added reference to jQuery.migrate
# $.browser || $.browser = {}

class XlfDetailView extends Backbone.View
  ###
  The XlfDetailView class is a base class for details
  of each row of the XLForm. When the view is initialized,
  a mixin from "DetailViewMixins" is applied.
  ###
  className: "dt-view"
  initialize: ({@rowView})->
    unless @model.key
      throw new XlformError "RowDetail does not have key"
    @extraClass = "xlf-dv-#{@model.key}"
    if (viewMixin = DetailViewMixins[@model.key])
      _.extend(@, viewMixin)
    @$el.addClass(@extraClass)

  render: ()->
    rendered = @html()
    if rendered
      @$el.html rendered
    @
  html: ()->
    viewTemplate.xlfDetailView @

  insertInDOM: (rowView)->
    rowView.rowExtras.append(@el)

  renderInRowView: (rowView)->
    @render()
    @afterRender && @afterRender()
    @insertInDOM(rowView)
    @

class XlfRowSelector extends Backbone.View
  events:
    "click .shrink": "shrink"
    "click .menu-item": "selectMenuItem"
  initialize: (opts)->
    @options = opts
    @button = @$el.find(".btn")
    @line = @$el.find(".line")
    if opts.action is "click-add-row"
      @expand()
  expand: ->
    $(".-form-editor .empty .survey-editor__message").css("display", "none")
    @button.fadeOut 150
    @line.addClass "expanded"
    @line.css "height", "inherit"
    @line.html viewTemplates.xlfRowSelector.line()
    $menu = @line.find(".well")
    mItems = [["geopoint"],
      ["image", "audio", "video", "barcode"],
      ["date", "datetime"],
      ["text", "integer", "decimal", "note"],
      # ["unk", "ellipse"],
      ["select_one", "select_multiple"]]
    for mrow in mItems
      menurow = $("<div>", class: "menu-row").appendTo $menu
      for mcell, i in mrow
        menurow.append viewTemplates.xlfRowSelector.cell mcell

  shrink: ->
    $(".-form-editor .empty .survey-editor__message").css("display", "")
    @line.find("div").eq(0).fadeOut 250, =>
      @line.empty()
    @button.fadeIn 200
    @line.removeClass "expanded"
    @line.animate height: "0"
  hide: ->
    @button.show()
    @line.empty().removeClass("expanded").css "height": 0
  selectMenuItem: (evt)->
    mi = $(evt.target).data("menuItem")
    rowBefore = @options.spawnedFromView?.model
    survey = @options.survey || rowBefore._parent
    rowBeforeIndex = survey.rows.indexOf(rowBefore)
    survey.addRowAtIndex({type: mi}, rowBeforeIndex+1)
    @hide()

class XlfOptionView extends Backbone.View
  tagName: "li"
  className: "xlf-option-view"
  events:
    "keyup input": "keyupinput"
  initialize: (@options)->
  render: ->
    @p = $("<span>")
    @c = $("<code> [<span>Automatic</span>]</code>")
    @d = $('<div>')
    if @model
      @p.html @model.get("label")
      @$el.attr("data-option-id", @model.cid)
      $('span', @c).html @model.get("name")
    else
      @model = new XLF.Option()
      @options.cl.options.add(@model)
      @p.html("Option #{1+@options.i}").addClass("preliminary")

    @p.editable success: _.bind @saveValue, @
    $('span', @c).editable success: (ev, val) =>
      val = XLF.sluggify val
      @model.set('name', val)
      @model.set('setManually', true)
      newValue: val
    @d.append(@p)
    @d.append(@c)
    @$el.html(@d)
    @
  keyupinput: (evt)->
    ifield = @$("input.inplace_field")
    if evt.keyCode is 8 and ifield.hasClass("empty")
      ifield.blur()

    if ifield.val() is ""
      ifield.addClass("empty")
    else
      ifield.removeClass("empty")
  saveValue: (ick, nval, oval, ctxt)->
    if nval is ""
      @$el.remove()
      @model.destroy()
    else
      @model.set("label", nval, silent: true)
      if !@model.get('setManually')
        @model.set("name", XLF.sluggify(nval), silent: true)
    ``

class XlfListView extends Backbone.View
  initialize: ({@rowView, @model})->
    @list = @model
    @row = @rowView.model
    @ulClasses = @$("ul").prop("className")
  render: ->
    @$el.html (@ul = $("<ul>", class: @ulClasses))
    if @row.get("type").get("rowType").specifyChoice
      for option, i in @model.options.models
        new XlfOptionView(model: option, cl: @model).render().$el.appendTo @ul
      while i < 2
        new XlfOptionView(empty: true, cl: @model, i: i).render().$el.appendTo @ul
        i++
      @$el.removeClass("hidden")
    else
      @$el.addClass("hidden")
    @ul.sortable({
        axis: "y"
        cursor: "move"
        distance: 5
        items: "> li"
        placeholder: "option-placeholder"
        opacity: 0.9
        scroll: false
        deactivate: =>
          if @hasReordered
            @reordered()
          true
        change: => @hasReordered = true
      })
    btn = $ viewTemplates.xlfListView.addOptionButton()
    btn.click ()=>
      i = @ul.find("li").length
      new XlfOptionView(empty: true, cl: @model, i: i).render().$el.appendTo @ul
    @$el.append(btn)
    @
  reordered: (evt, ui)->
    ids = []
    @ul.find("> li").each (i,li)=>
      lid = $(li).data("optionId")
      if lid
        ids.push lid
    for id, n in ids
      @model.options.get(id).set("order", n, silent: true)
    @model.options.comparator = "order"
    @model.options.sort()
    @hasReordered = false

class XlfRowView extends Backbone.View
  tagName: "li"
  className: "xlf-row-view"
  events:
   "click .create-new-list": "createListForRow"
   "click .edit-list": "editListForRow"
   "click": "select"
   "click .add-row-btn": "expandRowSelector"
   "drop": "drop"
   "click .row-extras-summary": "expandCog"
   "click .glyphicon-cog": "expandCog"
  initialize: (opts)->
    @options = opts
    typeDetail = @model.get("type")
    @$el.attr("data-row-id", @model.cid)
    # @model.on "change", @render, @
    # typeDetail.on "change:value", _.bind(@render, @)
    # typeDetail.on "change:listName", _.bind(@render, @)
    @surveyView = @options.surveyView
    @$el.on "xlf-blur", =>
      @$el.removeClass("xlf-selected")
  drop: (evt, index)->
    @$el.trigger("update-sort", [@model, index])
  select: ->
    unless @$el.hasClass("xlf-selected")
      $(".xlf-selected").trigger("xlf-blur")
      @$el.addClass("xlf-selected")
  expandRowSelector: ->
    #if !@xlfRowSelector
    @xlfRowSelector = new XlfRowSelector(el: @$el.find(".expanding-spacer-between-rows").get(0), spawnedFromView: @)
    @xlfRowSelector.expand()
  render: ->
    @$el.html viewTemplates.xlfRowView()

    unless (cl = @model.getList())
      cl = new XLF.ChoiceList()
      @model.setList(cl)
    @listView = new XlfListView(el: @$(".list-view"), model: cl, rowView: @).render()
    @rowContent = @$(".row-content")
    @rowExtras = @$(".row-extras")
    @rowExtrasSummary = @$(".row-extras-summary")
    for [key, val] in @model.attributesArray()
      new XlfDetailView(model: val, rowView: @).renderInRowView(@)

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

class @SurveyTemplateApp extends Backbone.View
  initialize: (@options)->
  render: ()->
    @$el.addClass("content--centered").addClass("content")
    @$el.html viewTemplates.surveyTemplateApp()
    @$(".btn--start-from-scratch").click ()=>
      new SurveyApp(@options).render()
    @

class @SurveyApp extends Backbone.View
  className: "formbuilder-wrap container"
  events:
    "click .delete-row": "clickRemoveRow"
    "click #preview": "previewButtonClick"
    "click #download": "downloadButtonClick"
    "click #save": "saveButtonClick"
    "click #publish": "publishButtonClick"
    "update-sort": "updateSort"

  initialize: (options)->
    if options.survey and (options.survey instanceof XLF.Survey)
      @survey = options.survey
    else
      @survey = new XLF.Survey(options)

    @rowViews = new Backbone.Model()

    @survey.rows.on "add", @softReset, @
    @survey.rows.on "remove", @softReset, @

    @onPublish = options.publish || $.noop
    @onSave = options.save || $.noop
    @onPreview = options.preview || $.noop

    $(window).on "keydown", (evt)=>
      @onEscapeKeydown(evt)  if evt.keyCode is 27
  updateSort: ()->
    # inspired by this:
    # http://stackoverflow.com/questions/10147969/saving-jquery-ui-sortables-order-to-backbone-js-collection
    @survey.rows.remove(model)
    @survey.rows.each (m, index)->
      m.ordinal = if index >= position then (index + 1) else index
    model.ordinal = position
    @survey.rows.add(model, at: position)

  render: ()->
    @$el.removeClass("content--centered").removeClass("content")
    @$el.html viewTemplates.surveyApp @survey
    
    @survey.settings.on 'validated:invalid', (model, validations) ->
      for key, value of validations
          break
    
    @formEditorEl = @$(".-form-editor")
    @$(".editor-message .expanding-spacer-between-rows .add-row-btn").click (evt)=>
      if !@emptySurveyXlfRowSelector
        @emptySurveyXlfRowSelector = new XlfRowSelector(el: @$el.find(".expanding-spacer-between-rows").get(0), survey: @survey)
      @emptySurveyXlfRowSelector.expand()

    viewUtils.makeEditable @, @survey.settings, '.form-title', property:'form_title'

    # see this page for info on what should be in a form_id
    # http://opendatakit.org/help/form-design/guidelines/
    viewUtils.makeEditable @, @survey.settings, '.form-id', property:'form_id', transformFunction:XLF.sluggify
    # @.survey.on 'change:form_id', _.bind viewUtils.handleChange('form_id', XLF.sluggify), @

    addOpts = @$("#additional-options")
    for detail in @survey.surveyDetails.models
      addOpts.append((new XlfSurveyDetailView(model: detail)).render().el)

    @softReset()

    @formEditorEl.sortable({
        axis: "y"
        cancel: "button,div.add-row-btn,.well,ul.list-view,li.editor-message, .editableform"
        cursor: "move"
        distance: 5
        items: "> li"
        placeholder: "placeholder"
        opacity: 0.9
        scroll: false
        activate: (evt, ui)-> ui.item.addClass("sortable-active")
        deactivate: (evt,ui)-> ui.item.removeClass("sortable-active")
      })
    @
  validateSurvey: ->
    # TODO. Implement basic validation
    true

  showValidationMessages: ->


  softReset: ->
    fe = @formEditorEl
    isEmpty = true
    @survey.forEachRow (row)=>
      isEmpty = false
      unless (xlfrv = @rowViews.get(row.cid))
        @rowViews.set(row.cid, new XlfRowView(model: row, surveyView: @))
        xlfrv = @rowViews.get(row.cid)

      $el = xlfrv.render().$el
      if $el.parents(@$el).length is 0
        @formEditorEl.append($el)

    @formEditorEl.find(".empty").css("display", if isEmpty then "" else "none")
    ``

  reset: ->
    fe = @formEditorEl.empty()
    @survey.forEachRow (row)=>
      # row._slideDown is for add/remove animation
      $el = new XlfRowView(model: row, surveyView: @).render().$el
      if row._slideDown
        row._slideDown = false
        fe.append($el.hide())
        $el.slideDown 175
      else
        fe.append($el)

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
      rowEl.slideUp 175, "swing", ()=>
        @survey.rows.trigger "reset"

  ensureAllRowsDrawn: ->
    prev = false
    @survey.forEachRow (row)=>
      prevMatch = @formEditorEl.find(".xlf-row-view[data-row-id='#{row.cid}']").eq(0)
      if prevMatch.length isnt 0
        prev = prevMatch
      else
        $el = new XlfRowView(model: row, surveyView: @).render().$el
        if prev
          prev.after($el)
        else
          @formEditorEl.prepend($el)

  onEscapeKeydown: -> #noop. to be overridden
  previewButtonClick: (evt)->
    @onPreview.call(@, arguments)
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

###
This is the view for the survey-wide details that appear at the bottom
of the survey. Examples: "imei", "start", "end"
###
class XlfSurveyDetailView extends Backbone.View
  className: "survey-header__option"
  events:
    "change input": "changeChkValue"
  initialize: ({@model})->
  render: ()->
    @$el.append viewTemplates.xlfSurveyDetailView @model
    @chk = @$el.find("input")
    @chk.prop "checked", true  if @model.get "value"
    @changeChkValue()
    @
  changeChkValue: ()->
    if @chk.prop("checked")
      @$el.addClass("active")
      @model.set("value", true)
    else
      @$el.removeClass("active")
      @model.set("value", false)

XLF.sluggify = (str)->
  # Convert text to a slug/xml friendly format.
  str.toLowerCase().replace(/\s/g, '_').replace(/\W/g, '').replace(/[_]+/g, "_")
