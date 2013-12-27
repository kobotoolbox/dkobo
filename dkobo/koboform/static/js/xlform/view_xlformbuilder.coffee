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
    @p = $("<p>")
    if @model
      @p.html @model.get("label")
      @$el.attr("data-option-id", @model.cid)
    else
      @model = new XLF.Option()
      @options.cl.options.add(@model)
      @p.html("Option #{1+@options.i}").addClass("preliminary")
    @p.editable success: _.bind @saveValue, @
    @$el.html(@p)
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
      @model.set("name", XLF.sluggify(nval), silent: true)
    null

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
  select: ->
    unless @$el.hasClass("xlf-selected")
      $(".xlf-selected").trigger("xlf-blur")
      @$el.addClass("xlf-selected")
  expandRowSelector: ->
    if !@xlfRowSelector
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

  render: ()->
    @$el.removeClass("content--centered").removeClass("content")
    @$el.html viewTemplates.surveyApp @survey

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

###
  # Details that need to be presented for each row:
  # 1. type
  #   - if (select_one|select_multiple) then list
  # 2. name
  # 3. hint?
  # 4. required?

  # For future development:
  # -----------------------
  # * Make group?
  # * Constraint?
  # * Calculation
  # * Media?
###

### Removed from UI
class XLF.ManageListView extends Backbone.View
  initialize: ({@rowView})->
    @row = @rowView.model
    @survey = @row._parent
    ``
  className: "manage-list-view col-md-4"
  events:
    "click .expand-list": "expandList"
  expandList: (evt)->
    evt.preventDefault()
    row = @row
    summ = @$(".bc-wrap.summarized")
    dims = width: summ.find("select").width()
    exp = @$(".bc-wrap.expanded")

    list = row.getList()
    taVals = []
    for opt in list.options.models
      taVals.push opt.get("label")
    placeHolderText = """Enter 1 option per line"""
    # exp.html("""
    #   <div class="iwrap">
    #     <div class="cf">
    #       <h4 class="list-name">#{list.get("name")}</h4>
    #       <p class="buttons"><button class="cl-save">Save</button><button class="cl-cancel">Cancel</button></p>
    #     </div>
    #     <textarea style="height:#{19 * taVals.length}px" placeholder="#{placeHolderText}">#{taVals.join("\n")}</textarea>
    #   </div>
    #   """)
    # exp.find("h4").eq(0).css(dims)
    hideCl = ->
      exp.hide()
      summ.show()

    summH = summ.find(".selected-list-summary").height()
    exp.html summ.html()
    exp.find(".n-lists-available").html viewTemplates.xlfManageListView.buttons()
    saveButt = exp.find(".cl-save").bind "click", hideCl
    exp.find(".cl-cancel").bind "click", hideCl
    taLineH = 19
    ta = $("<textarea>").html(taVals.join("\n")).css("height", summH)
    summ2 = exp.find(".selected-list-summary")
    summ2.html(ta)
    resizeTa = (evt)->
      lineCt = ta.data("line-count")
      valLines = ta.val().split("\n").length
      if lineCt isnt valLines and valLines >= 2
        ta.css("height", valLines * taLineH)
        ta.data("line-count", valLines)

    @rowView.surveyView.onEscapeKeydown = (evt)=>
      hideCl()

    ta.on "keyup", resizeTa
    ta.on "blur", ->
      taVals = for line in ta.val().split("\n") when line.match(/\w+/)
        name: XLF.sluggify(line), label: line
      opts = new XLF.Options(taVals)
      saveButt.unbind("click")
      saveButt.bind "click", ->
        list.options = opts
        hideCl()
        row.trigger("change")
    h2 = taVals.length * taLineH
    ta.animate({height: h2}, 275)

  render: ->
    numChoices = @survey.choices.models.length
    list = @row.getList()
    listName = @row.get("type").get("listName")
    editMode = @rowView.$el.find(".edit-list-view").length isnt 0

    uid = _.uniqueId("list-select-")

    @$el.append viewTemplates.xlfManageListView uid

    select = @$el.find("select")

    # bc_wrap = $("<div>", class: "bc-wrap cf summarized").appendTo @$el
    # bc_wrap_hidden = $("<div>", class: "bc-wrap cf expanded").hide().appendTo @$el
    # a_selectBox = $("<div>", class: "select-list-box").appendTo bc_wrap

    # c_nListsAvailable = $("<div>", class: "n-lists-available").appendTo bc_wrap
    # b_selectedListSummary = $("<div>", class: "selected-list-summary").appendTo bc_wrap

    # c_nListsAvailable.text "#{numChoices} list#{if numChoices is 1 then '' else 's'} available "


    if list
      table = $ viewTemplates.xlfManageListView.table list
      for opt, n in list.options.models
        tr = $("<tr>").appendTo(table)
        $("<td>").text(n+".").appendTo(tr)
        $("<td>").text(opt.get("name")).appendTo(tr)
      table.appendTo @$el
      opts = (opt.get("name")  for opt in list.options.models)
      optsStr = "#{opts.join(',')}"
      maxChars = 30
      if optsStr.length > maxChars
        optsStr = optsStr.slice(0,maxChars) + "..."
      # b_selectedListSummary.html "<a href='#' class='expand-list'>[ #{optsStr} ]</a>"
    else
      # b_selectedListSummary.html "<em>No list selected</em>"

    if numChoices is 0
      sel = $("<select>", {disabled: 'disabled'}).html($("<option>", text: "No lists available"))
      # a_selectBox.html sel
    else
      sel = $("<select>")
      unless list
        placeholder = $("<option>", value: "", selected: "selected").html("Select a list...")
        sel.append(placeholder)
        sel.addClass("placeholding")
        sel.focus (evt)-> sel.removeClass("placeholding")
        sel.change (evt)-> placeholder.remove()

      for choiceList in @survey.choices.models
        clName = choiceList.get("name")
        if list and clName is list.get("name")
          opt = $("<option>", value: clName, selected: "selected")
        else
          opt = $("<option>", value: clName)
        opt.html(clName).appendTo(sel)
      sel.change (evt)=>
        nextList = @survey.choices.get $(evt.target).val()
        @row.get("type").set("list", nextList)
      # a_selectBox.html sel
    # c_nListsAvailable.append """<button class='create-new-list2'>(+) Create new list</button>"""
    @

class XLF.EditListView extends Backbone.View
  initialize: ({@survey, @rowView, @choiceList})->
    @collection = @choiceList.options
    if @collection.models.length is 0
      @collection.add placeholder: "Option 1"
      @collection.add placeholder: "Option 2"
    @collection.bind "change reset add remove", ()=> @render()

  className: "edit-list-view"
  events:
    "click .list-ok": "saveList"
    "click .list-cancel": "closeList"
    "click .list-add-row": "addRow"
    "click .list-delete-row": "deleteRow"
  render: ->
    @$el.html viewTemplates.xlfEditListView @choiceList
    nameEl = @$(".name")
    nameEl.text(name)  if (name = @choiceList.get("name"))
    
    viewUtils.handleChange 'name', XLF.sluggify

    viewUtils.makeEditable @, '.name', 'name'

    optionsEl = @$(".options")
    for c in @collection.models
      do (option=c)->
        inp = $("<input>", placeholder: option.get("placeholder"))
        if (label = option.get("label"))
          inp.val(label)
        inp.change (evt)->
          val = $(evt.target).val()
          cleanedVal = XLF.sluggify val
          option.set "label", val
          option.set "name", cleanedVal
          ``
        optionsEl.append $("<p>").html(inp)
    @
  saveList: ->
    if @choiceList.isValid()
      @survey.choices.add @choiceList
      if @rowView
        @rowView.model.get("type").set("list", @choiceList)
      @_remove =>
        @survey.trigger "change"
    else
      @$(".error").text("Error saving: ").show()
  closeList: ->
    @_remove()
  _remove: (cb)->
    @$el.slideUp 175, "swing", =>
      @$el.remove()
      cb()
  addRow: ->
    @collection.add placeholder: "New option"
  deleteRow: ->
    log "Not yet implemented"
###

###
Helper methods:
  sluggify
###
XLF.sluggify = (str)->
  # Convert text to a slug/xml friendly format.
  str.toLowerCase().replace(/\s/g, '_').replace(/\W/g, '').replace(/[_]+/g, "_")
