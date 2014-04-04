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
        name = row.cid
        label = row.getValue("label")
        options += '<option value="' + name + '">' + label + "</option>"
      options

    @$el.html render_questions()

    @$el.on 'change', () =>
      @$el.children(':first').prop('disabled', true)

    @

  constructor: (@questions, @survey) ->
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

class XLF.Views.SkipLogicValidatingTextResponseView extends XLF.Views.SkipLogicTextResponse
  render: () ->
    @setElement('<div class="skiplogic__responseval-wrapper"><input placeholder="response value" class="skiplogic__responseval" type="text" /><div></div></div>')
    @$error_message = @$('div')
    @model.bind('validated:invalid', @show_invalid_view)
    @model.bind('validated:valid', @clear_invalid_view)
    @
  show_invalid_view: (model, errors) =>
    if @$('input').val()
      @$el.addClass('textbox--invalid')
      @$error_message.html(errors.value)
  clear_invalid_view: (model, errors) =>
    @$el.removeClass('textbox--invalid')
    @$error_message.html('')
  fill_value: (value) ->
    @$('input').val(value)


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

  response_value_handler: () ->
    @presenter.change_response @$response_value.val()

  change_operator: (@operator_picker_view) ->
    @operator_picker_view.render()
    @$operator_picker.replaceWith(@operator_picker_view.el)

    @$operator_picker = @$('.skiplogic__expressionselect')
    @bind_operator_picker()

  change_response: (@response_value_view) ->
    @response_value_view.render()
    if @$('.skiplogic__responseval-wrapper').length > 0
      @$('.skiplogic__responseval-wrapper').replaceWith(@response_value_view.el)
    else
      @$response_value.replaceWith(@response_value_view.el)

    @$response_value = @$('.skiplogic__responseval')

    @bind_response_value()

  constructor: (@question_picker_view, @operator_picker_view, @response_value_view, @presenter) ->
    super()

class XLF.Views.SkipLogicViewFactory
  create_question_picker: (questions) ->
    new XLF.Views.QuestionPicker questions, @survey
  create_operator_picker: (operators) ->
    new XLF.Views.OperatorPicker operators
  create_response_value_view: (type, responses) ->
    switch type
      when 'empty' then new XLF.Views.SkipLogicEmptyResponse
      when 'text' then new XLF.Views.SkipLogicTextResponse
      when 'dropdown' then new XLF.Views.SkipLogicDropDownResponse responses
      when 'integer', 'decimal' then new XLF.Views.SkipLogicValidatingTextResponseView
  create_criterion_view: (question_picker_view, operator_picker_view, response_value_view, presenter) ->
    return new XLF.Views.SkipLogicCriterion question_picker_view, operator_picker_view, response_value_view, presenter
  constructor: (@survey) ->
