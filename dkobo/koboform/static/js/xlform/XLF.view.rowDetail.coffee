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
        @skipLogicEditor = new XLF.SkipLogicCollectionView(el: @$el.find(".relevant__editor"), model: @model)
        @skipLogicEditor.builder = @model.builder
        @skipLogicEditor.render()

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

class XLF.Views.Base extends Backbone.View
  attach_to: ($el) ->
    $el.append(@el)

  fill_value: (value) ->
    @$el.val value
    if !@$el.val()?
      @$el.prop('selectedIndex', 0);

class XLF.SkipLogicCriterionBuilderView extends XLF.Views.Base
  events:
    "click .skiplogic__deletecriterion": "deleteCriterion"
    "click .skiplogic__addcriterion": "addCriterion"
    "click .skiplogic__delimselectcb": "markChangedDelimSelector"
  render: () ->
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
    """)

    delimSelect = @$(".skiplogic__delimselect")

    for checkbox in delimSelect.find("input") when checkbox.value is @criterion_delimiter
      checkbox.checked = "checked"

    @

  addCriterion: (evt) =>
    @facade.add_empty()
  deleteCriterion: (evt)->
    $target = $(evt.target)
    modelId = $target.data("criterionId")
    @facade.remove modelId
    $target.parent().remove()

  markChangedDelimSelector: (evt) ->
    @criterion_delimiter = evt.target.value

class XLF.SkipLogicHandCodeView extends XLF.Views.Base
  render: () ->
    @$el.html('<textarea class="skiplogic__handcode-edit"></textarea>')
    @

###
SkipLogicCollectionView
###
class XLF.SkipLogicCollectionView extends Backbone.View
  render: ()->
    @$el.html("""
      <div class="skiplogic__main"></div>
      <p class="skiplogic__extras">
        <button class="skiplogic__handcode">Hand code</button>
      </p>
    """)

    @target_element = @$('.skiplogic__main')

    @facade = @builder.build()
    @facade.render @target_element
    @model.facade = @facade

    @$('.skiplogic__handcode').click(_.bind @switchEditingMode, @)
    @
  toggle: ->
    @$el.toggle()
  switchEditingMode: () =>
    @facade = @facade.switch_editing_mode()
    @target_element.empty()
    @facade.render @target_element
    @model.facade = @facade

class XLF.Views.QuestionPicker extends XLF.Views.Base
  tagName: 'select'
  className: 'skiplogic__rowselect'
  render: () ->
    render_questions = () =>
      options = '<option value="-1">Question...</option>'
      _.each @questions, (row) ->
        name = row.getValue("name")
        label = row.getValue("label")
        options += '<option value="' + name + '">' + label + "</option>"
      options

    @$el.html render_questions()

    @$el.on 'change', () =>
      @$el.children(':first').prop('disabled', true)

    @

  constructor: (@questions) ->
    super()

class XLF.Views.OperatorPicker extends XLF.Views.Base
  tagName: 'select'
  className: 'skiplogic__expressionselect'
  render: () ->
    render_operators = () =>
      options = ''
      _.each @operators, (operator) ->
        options += '<option value="' + operator.id + '">' + operator.label + '</option>'
        options += '<option value="-' + operator.id + '">' + operator.negated_label + '</option>'
      options

    @$el.html render_operators()
    if @value
      @fill_value @value

    @

  constructor: (@operators) ->
    super()


class XLF.Views.SkipLogicEmptyResponse extends XLF.Views.Base
  className: 'skiplogic__responseval'
  fill_value: (value) ->

class XLF.Views.SkipLogicTextResponse extends XLF.Views.Base
  render: () ->
    @setElement('<input placeholder="response value" class="skiplogic__responseval" type="text" />')
    @

class XLF.Views.SkipLogicIntegerResponseView extends XLF.Views.SkipLogicTextResponse
  render: () ->
    super()
    @$el.on 'blur', () ->
      is_valid = @facade

class XLF.Views.SkipLogicDropDownResponse extends XLF.Views.Base
  tagName: 'select'
  className: 'skiplogic__responseval'
  render: () ->
    render_response_values = () =>
      options = ''
      @responses.forEach (response) ->
        options += '<option value="' + response.get('name') + '">' + response.get('label') + '</option>'
      options

    @$el.html render_response_values()

    @

  constructor: (@responses) ->
    super()

class XLF.Views.SkipLogicCriterion extends XLF.Views.Base
  tagName: 'div'
  render: () ->

    @question_picker_view.render().attach_to @$el
    @operator_picker_view.render().attach_to @$el
    @response_value_view.render().attach_to @$el

    @$el.append $("""<button class="skiplogic__deletecriterion" data-criterion-id="#{@model.cid}">&times;</button>""")

    @$question_picker = @$('.skiplogic__rowselect')
    @$operator_picker = @$('.skiplogic__expressionselect')
    @$response_value = @$('.skiplogic__responseval')

    @bind_question_picker()
    @bind_response_value()
    @bind_operator_picker()

    @

  bind_question_picker: () ->
    @$question_picker.on 'change', () =>
      @presenter.change_question @$question_picker.val()

  bind_operator_picker: () ->
    @$operator_picker.on 'change', () =>
      @presenter.change_operator @$operator_picker.val()

  bind_response_value: () ->
    @$response_value.on (if @$response_value.prop('tagName') == 'select' then 'change' else 'blur'), () =>
      @presenter.change_response @$response_value.val()

  change_operator: (@operator_picker_view) ->
    @operator_picker_view.render()
    @$operator_picker.replaceWith(@operator_picker_view.el)

    @$operator_picker = @operator_picker_view.$el
    @bind_operator_picker()

  change_response: (@response_value_view) ->
    @response_value_view.render()
    @$response_value.replaceWith(@response_value_view.el)

    @$response_value = @response_value_view.$el
    @bind_response_value()

  constructor: (@question_picker_view, @operator_picker_view, @response_value_view, @presenter) ->
    super()

class XLF.Views.SkipLogicViewFactory
  create_question_picker: (questions) ->
    new XLF.Views.QuestionPicker questions
  create_operator_picker: (operators) ->
    new XLF.Views.OperatorPicker operators
  create_response_value_view:
    empty: () ->
      return new XLF.Views.SkipLogicEmptyResponse
    text: () ->
      return new XLF.Views.SkipLogicTextResponse
    dropdown: (responses) ->
      return new XLF.Views.SkipLogicDropDownResponse responses
  create_criterion_view: (question_picker_view, operator_picker_view, response_value_view, presenter) ->
    return new XLF.Views.SkipLogicCriterion question_picker_view, operator_picker_view, response_value_view, presenter