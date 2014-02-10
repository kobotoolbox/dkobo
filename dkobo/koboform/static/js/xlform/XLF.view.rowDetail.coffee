# class XlfDetailView extends Backbone.View
# class XLF.SkipLogicCriterionView extends Backbone.View
# class XLF.SkipLogicCollectionView extends Backbone.View

class XLF.DetailView extends Backbone.View
  ###
  The XlfDetailView class is a base class for details
  of each row of the XLForm. When the view is initialized,
  a mixin from "XLF.DetailViewMixins" is applied.
  ###
  className: "dt-view"
  initialize: ({@rowView})->
    unless @model.key
      throw new Error "RowDetail does not have key"
    @extraClass = "xlf-dv-#{@model.key}"
    if (viewMixin = XLF.DetailViewMixins[@model.key])
      _.extend(@, viewMixin)
    else
      console?.error "couldn't find ", @model.key
    @$el.addClass(@extraClass)

  render: ()->
    rendered = @html()
    if rendered
      @$el.html rendered
    @
  html: ()->
    viewTemplates.xlfDetailView @

  insertInDOM: (rowView)->
    rowView.rowExtras.append(@el)

  renderInRowView: (rowView)->
    @render()
    @afterRender && @afterRender()
    @insertInDOM(rowView)
    @


XLF.DetailViewMixins = {}

XLF.DetailViewMixins.type =
  html: -> false
  insertInDOM: (rowView)->
    typeStr = @model.get("value").split(" ")[0]
    faClass = XLF.icons.get(typeStr).get("faClass")
    rowView.$el.find(".card__header-icon").addClass("fa-#{faClass}")

XLF.DetailViewMixins.label =
  html: -> false
  insertInDOM: (rowView)->
    cht = rowView.$el.find(".card__header-title")
    cht.html(@model.get("value"))
    viewUtils.makeEditable @, @model, cht, options:
      placement: 'right'
      rows: 3

XLF.DetailViewMixins.hint =
  html: ->
    """
    #{@model.key}: <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, 'code', {}

XLF.DetailViewMixins.relevant =
  html: ->
    """
      <button>Skip Logic</button>
      <div class="relevant__editor"></div>
    """

  afterRender: ->
    button = @$el.find("button").eq(0)
    button.click () =>
      if @skipLogicEditor
        @skipLogicEditor.toggle()
      else
        if !@model.skipLogicCollection
          console?.error("Skip Logic Colleciton not found for RowDetail model.")
        @skipLogicEditor = new XLF.SkipLogicCollectionView(el: @$el.find(".relevant__editor"), collection: @model.skipLogicCollection).render()

XLF.DetailViewMixins.constraint =
  html: ->
    """
      Validation logic (i.e. <span style='font-family:monospace'>constraint</span>):
      <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, 'code', {}

XLF.DetailViewMixins.name = XLF.DetailViewMixins.default =
  html: ->
    """
    #{@model.key}: <code>#{@model.get("value")}</code>
    """
  afterRender: ->
    viewUtils.makeEditable @, @model, "code", transformFunction: XLF.sluggify

XLF.DetailViewMixins.required =
  html: ->
    """<label><input type="checkbox"> Required?</label>"""
  afterRender: ->
    inp = @$el.find("input")
    inp.prop("checked", @model.get("value"))
    inp.change ()=> @model.set("value", inp.prop("checked"))


###
SkipLogicCollectionView
###
class XLF.SkipLogicCollectionView extends Backbone.View
  events:
    "click .skiplogic__deletecriterion": "deleteCriterion"
    "click .skiplogic__addcriterion": "addCriterion"
    "click .skiplogic__delimselectcb": "markChangedDelimSelector"
  initialize: ()->
    @collection.on("add", _.bind(@render,@))
    @collection.on("remove", _.bind(@render,@))
  render: ()->
    tempId = _.uniqueId("skiplogic_expr")
    @$el.html("""
    <p class="skiplogic__addnew">
      <button class="skiplogic__addcriterion">Add new</button>
    </p>
    <p class="skiplogic__delimselect">
      Match all or any of these criteria?
      <br>
      <label>
        <input type="radio" class="skiplogic__delimselectcb" name="#{tempId}" value="and" />
        All
      </label>
      <label>
        <input type="radio" class="skiplogic__delimselectcb" name="#{tempId}" value="or" />
        Any
      </label>
    </p>
    <div class="skiplogic__criterialist"></div>
    <p class="skiplogic__extras">
      <button class="skiplogic__handcode">Hand code</button>
    </p>
    <textarea class="skiplogic__handcode-edit"></textarea>
    """)
    @$list = @$(".skiplogic__criterialist")

    delimSelect = @$(".skiplogic__delimselect")
    delimSelect[if @collection.length < 2 then "hide" else "show"]()
    delimSelectValue = @collection.meta.get("delimSelect")
    for checkbox in delimSelect.find("input") when checkbox.value is delimSelectValue
      checkbox.checked = "checked"

    if @collection.meta.get("mode") == "gui"
      @collection.each (model)=>
        @$list.append(new XLF.SkipLogicCriterionView(model: model).render().$el)
      @$list.show()
      @$('.skiplogic__addcriterion').show()
      @$('.skiplogic__handcode-edit').hide()
    else
      @$list.hide()
      delimSelect.hide()
      @$('.skiplogic__addcriterion').hide()
      wire_up_input(@$('.skiplogic__handcode-edit').show(), @collection.at(0), 'value')

    @$('.skiplogic__handcode').click(_.bind @switchEditingMode, @)
    @
  markChangedDelimSelector: (evt) ->
    @collection.meta.set("delimSelect", evt.target.value)
  toggle: ->
    @$el.toggle()
  addCriterion: (evt)->
    @collection.add(_parent: @collection._parent)
  deleteCriterion: (evt)->
    $target = $(evt.target)
    modelId = $target.data("criterionId")
    criterion = @collection.get(modelId)
    @collection.remove(criterion)
  switchEditingMode: (evt) ->
    @collection.switchEditingMode()
    @render()


class XLF.SkipLogicCriterionView extends Backbone.View
  initialize: ()->
    @model.on("change:expressionCode", _.bind(@render,@))
  lookupExpression: (expr)->
    for key, vals of XLF.SkipLogicCriterion.expressionValues when key is expr
      return vals
    throw new Error("Expression not found: #{str}")
  render: ()->
    question = @model.get('question')
    @response_value_is_select = !!(question? && question.getType() == 'select_one')

    @$el.html("""
      <select class="skiplogic__rowselect on-row-detail-change-name on-row-detail-change-label"></select>
    """ +
    @render_expression_select() +
    (if @response_value_is_select then """<select class="skiplogic__responseval" style="width: 100px;"></select>""" else """<input placeholder="response value" class="skiplogic__responseval" type="text" />""") +
    """
      <button class="skiplogic__deletecriterion" data-criterion-id="#{@model.cid}">&times;</button>
    """)

    @populate_expressionselect()
    @listen_expressionselect()
    @hide_expressionSelect_if_singular()

    @populate_rowselect()
    @$(".skiplogic__rowselect").on "row-detail-change-name row-detail-change-label", =>
      @populate_rowselect()

    @listen_rowselect()
    @populate_responseval()

    @

  render_expression_select: ->
    if @response_value_is_select
      " was "
    else
      """
        <select class="skiplogic__expressionselect">
          <option value="resp_equals">was</option>
          <option value="resp_notequals">was not</option>
          <option value="ans_notnull">was answered</option>
          <option value="ans_null">was not answered</option>
        </select>
      """
  populate_responseval: ->
    $response_value_input = if @response_value_is_select then @$('select.skiplogic__responseval') else @$('.skiplogic__responseval')

    if (@response_value_is_select)
      question = @model.get('question')
      if question
        choiceListId = question.getList().cid
        $response_value_input.attr("data-choice-list-cid", choiceListId)
        $response_value_input.addClass("on-choice-list-update")

      $response_value_input.on "rebuild-choice-list", ()=>
        $response_value_input.empty()
        @model.get('question').getList().options.forEach (option) =>
          $("<option>", {value: option.get('name'), html: option.get('label')}).appendTo($response_value_input)

        modelCriterion = @model.get("criterionOption")
        if modelCriterion
          $response_value_input.val(modelCriterion.get('name'))
        $response_value_input.select2()

      $response_value_input.trigger("rebuild-choice-list")

      link_selected_option = ()=>
        selectedOption = @model.get("question").getList().options.get($response_value_input.val())
        @model.set("criterionOption", selectedOption)

      $response_value_input.on "change", link_selected_option

      link_selected_option()

    else
      wire_up_input($response_value_input, @model, 'criterion', 'keyup')
  populate_expressionselect: ->
    expressionSelect = @$(".skiplogic__expressionselect")
    for key, vals in XLF.SkipLogicCriterion.expressionValues
      $("<option>", value: key, text: vals[1]).appendTo(expressionSelect)
    expressionCode = @model.get("expressionCode")
    expressionSelect.val(expressionCode)
    ``

  listen_expressionselect: ->
    expressionSelect = @$(".skiplogic__expressionselect")
    expressionSelect.off "change"
    expressionSelect.on "change", (evt)=>
      expStr = @lookupExpression(evt.target.value)[0]
      @model.set("expressionCode", evt.target.value)
    ``

  populate_rowselect: ()->
    question = @model.get("question")
    parent_row = @model._parent
    survey = @model.getSurvey()

    skiplogic__rowselect = $('select.skiplogic__rowselect', @$el).eq(0).empty()
    $("<option>", {value: '-1', html: 'Question...', disabled: !!question}).appendTo(skiplogic__rowselect)

    limit = false

    survey.forEachRow (row)->
      limit = limit || row is parent_row
      if !limit
        name = row.getValue("name")
        label = row.getValue("label")
        $("<option>", {value: name, html: label}).appendTo(skiplogic__rowselect)

    if question
      questionName = question.getValue("name")
      skiplogic__rowselect.val(questionName)

    disableDefaultOption = () ->
      $('option[value=-1]', skiplogic__rowselect).prop('disabled', true)
      skiplogic__rowselect.off('change', disableDefaultOption)
    skiplogic__rowselect.on('change', disableDefaultOption)
    skiplogic__rowselect.select2()
    ``

  listen_rowselect: ->
    skiplogic__rowselect = @$("select.skiplogic__rowselect")
    parent_row = @model._parent
    if !parent_row
      console?.error("@model has no _parent yet", @model)
      parent_row = @model.get("parentRow")
    survey = parent_row.getSurvey()
    skiplogic__rowselect.off "change"
    skiplogic__rowselect.on "change", ()=>
      questionName = skiplogic__rowselect.val()
      question = survey.findRowByName(questionName)
      if question
        @model.set("question", question)
        @render()
      else
        throw new Error("Question `#{questionName}` not found")
    ``

  hide_expressionSelect_if_singular: ->
    EXVALS = XLF.SkipLogicCriterion.expressionValues
    expressionCode = @model.get("expressionCode")
    unless expressionCode of EXVALS
      throw new Error("ExpressionCode not recognized: #{expressionCode}")
    [exprStr, descLabel, addlReqs] = EXVALS[expressionCode]
    unless addlReqs
      @$(".skiplogic__responseval").css("display", "none")
    ``

wire_up_input = ($input, model, name, event='change') =>
  if model.get(name)
    $input.val(model.get(name))
  $input.on(event, () => model.set(name, $input.val()))
  ``
