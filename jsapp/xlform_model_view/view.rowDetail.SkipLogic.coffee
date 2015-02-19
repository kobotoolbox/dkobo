define 'cs!xlform/view.rowDetail.SkipLogic', [
        'backbone',
        'xlform/model.rowDetails.skipLogic',
        'cs!xlform/view.widgets'
        ], (
            Backbone,
            $modelRowDetailsSkipLogic,
            $viewWidgets
            )->

  viewRowDetailSkipLogic = {}

  class viewRowDetailSkipLogic.SkipLogicCriterionBuilderView extends $viewWidgets.Base
    events:
      "click .skiplogic__deletecriterion": "deleteCriterion"
      "click .skiplogic__addcriterion": "addCriterion"
      "change .skiplogic__delimselect": "markChangedDelimSelector"
    render: () ->
      tempId = _.uniqueId("skiplogic_expr")
      @$el.html("""
        <p>
          This question will only be displayed if the following conditions apply
        </p>
        <div class="skiplogic__criterialist"></div>
        <p class="skiplogic__addnew">
          <button class="skiplogic__addcriterion">+ Add another condition</button>
        </p>
        <select class="skiplogic__delimselect">
          <option value="and">Question should match all of these criteria</option>
          <option value="or">Question should match any of these criteria</option>
        </select>
      """)

      delimSelect = @$(".skiplogic__delimselect").val(@criterion_delimiter)

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

  class viewRowDetailSkipLogic.QuestionPicker extends $viewWidgets.DropDown
    tagName: 'select'
    className: 'skiplogic__rowselect'

    render: () ->
      super
      @$el.on 'change', () =>
        @$el.children(':first').prop('disabled', true)
      @

    attach_to: (target) ->
      target.find('.skiplogic__rowselect').remove()
      super(target)


  class viewRowDetailSkipLogic.OperatorPicker extends $viewWidgets.Base
    tagName: 'div'
    className: 'skiplogic__expressionselect'
    render: () ->
      @

    attach_to: (target) ->
      target.find('.skiplogic__expressionselect').remove()
      super(target)

      @$el.select2({
        minimumResultsForSearch: -1
        data: do () =>
          operators = []
          _.each @operators, (operator) ->
            operators.push id: operator.id, text: operator.label + (if operator.id != 1 then ' (' + operator.symbol[operator.parser_name[0]] + ')' else '')
            operators.push id: '-' + operator.id, text: operator.negated_label + (if operator.id != 1 then ' (' + operator.symbol[operator.parser_name[1]] + ')' else '')

          operators
      })

      if @value
        @val @value
      else
        @value = @$el.select2('val')

      @$el.on 'select2-close', () => @_set_style()

    val: (value) ->
      if value?
        @$el.select2 'val', value
        @_set_style()
        @value = value
      else
        return @$el.val()

    _set_style: () -> #violates LSP
      @$el.toggleClass 'skiplogic__expressionselect--no-response-value', +@$el.val() in [-1, 1]
      absolute_value = if @$el.val() >= 0 then +@$el.val() else -@$el.val()
      if absolute_value == 0
        return

      operator = _.find @operators, (operator) ->
        operator.id == absolute_value

      abbreviated_label = operator['abbreviated_' + (if +@$el.val() < 0 then 'negated_' else '') + 'label']
      chosen_element = @$el.parents('.skiplogic__criterion').find('.select2-container.skiplogic__expressionselect .select2-chosen')
      chosen_element.text(abbreviated_label)

    constructor: (@operators) ->
      super()


  class viewRowDetailSkipLogic.SkipLogicEmptyResponse extends $viewWidgets.EmptyView
    className: 'skiplogic__responseval'
    attach_to: (target) ->
      target.find('.skiplogic__responseval').remove()
      super(target)

  class viewRowDetailSkipLogic.SkipLogicTextResponse extends $viewWidgets.TextBox
    attach_to: (target) ->
      target.find('.skiplogic__responseval').remove()
      super

    bind_event: (handler) ->
      @$el.on 'blur', handler

    constructor: (text) ->
      super(text, "skiplogic__responseval", "response value")

  class viewRowDetailSkipLogic.SkipLogicValidatingTextResponseView extends viewRowDetailSkipLogic.SkipLogicTextResponse
    render: () ->
      super
      @setElement('<div class="skiplogic__responseval-wrapper">' + @$el + '<div></div></div>')
      @$error_message = @$('div')
      @model.bind 'validated:invalid', @show_invalid_view
      @model.bind 'validated:valid', @clear_invalid_view
      @$input = @$el.find('input')
      @
    show_invalid_view: (model, errors) =>
      if @$input.val()
        @$el.addClass('textbox--invalid')
        @$error_message.html(errors.value)
        @$input.focus()
    clear_invalid_view: (model, errors) =>
      @$el.removeClass('textbox--invalid')
      @$error_message.html('')

    bind_event: (handler) ->
      @$input.on 'blur', handler

    val: (value) =>
      if value?
        @$input.val(value)
      else
        @$input.val()

  class viewRowDetailSkipLogic.SkipLogicDropDownResponse extends $viewWidgets.DropDown
    tagName: 'select'
    className: 'skiplogic__responseval'

    attach_to: (target) ->
      target.find('.skiplogic__responseval').remove()
      super(target)

    bind_event: (handler) ->
      super 'change', handler


    constructor: (@responses) ->
      super(_.map @responses.models, (response) ->
        text: response.get('label')
        value: response.get('name')
      )

  class viewRowDetailSkipLogic.SkipLogicCriterion extends $viewWidgets.Base
    tagName: 'div'
    className: 'skiplogic__criterion'
    render: () ->

      @question_picker_view.render()

      @$el.append $("""<i class="skiplogic__deletecriterion fa fa-trash-o" data-criterion-id="#{@model.cid}"></i>""")

      @change_operator @operator_picker_view
      @change_response @response_value_view

      @

    mark_question_specified: (is_specified=false) ->
      @$el.toggleClass("skiplogic__criterion--unspecified-question", not is_specified)

    bind_question_picker: () ->
      @mark_question_specified +@$question_picker.val() != -1

      @$question_picker.on 'change', (e) =>
        @mark_question_specified true
        # @presenter.change_question @$question_picker.val()
        # replaced with e.val because of select2
        @presenter.change_question e.val

    bind_operator_picker: () ->
      @$operator_picker.on 'change', () =>
        @operator_picker_view.value = @$operator_picker.select2 'val'
        @presenter.change_operator @operator_picker_view.value

    bind_response_value: () ->
      @response_value_view.bind_event () =>
        @presenter.change_response @response_value_view.val()

    response_value_handler: () ->
      @presenter.change_response @response_value_view.val()

    change_operator: (@operator_picker_view) ->
      @operator_picker_view.render()

      @$operator_picker = @operator_picker_view.$el

    change_response: (response_value_view) ->
      @response_value_view.detach()
      @response_value_view = response_value_view
      @response_value_view.render()

      @$response_value = @response_value_view.$el

    attach_operator: () ->
      @operator_picker_view.attach_to @$el
      @bind_operator_picker()

    attach_response: () ->
      if @$('.skiplogic__responseval-wrapper').length > 0
        @$('.skiplogic__responseval-wrapper').remove()

      @response_value_view.attach_to(@$el)
      @bind_response_value()

    attach_to: (element) ->
      @question_picker_view.attach_to @$el
      @$question_picker = @question_picker_view.$el
      @bind_question_picker()
      @attach_operator()
      @attach_response()
      super

    constructor: (@question_picker_view, @operator_picker_view, @response_value_view, @presenter) ->
      super()

  class viewRowDetailSkipLogic.SkipLogicViewFactory
    constructor: (@survey) ->
    create_question_picker: (questions) ->
      new viewRowDetailSkipLogic.QuestionPicker questions, @survey
    create_operator_picker: (operators) ->
      new viewRowDetailSkipLogic.OperatorPicker operators
    create_response_value_view: (type, responses) ->
      switch type
        when 'empty' then new viewRowDetailSkipLogic.SkipLogicEmptyResponse()
        when 'text' then new viewRowDetailSkipLogic.SkipLogicTextResponse
        when 'dropdown' then new viewRowDetailSkipLogic.SkipLogicDropDownResponse responses
        when 'integer', 'decimal' then new viewRowDetailSkipLogic.SkipLogicTextResponse
        else null
    create_criterion_view: (question_picker_view, operator_picker_view, response_value_view, presenter) ->
      return new viewRowDetailSkipLogic.SkipLogicCriterion question_picker_view, operator_picker_view, response_value_view, presenter
    create_criterion_builder_view: () ->
      return new viewRowDetailSkipLogic.SkipLogicCriterionBuilderView()
    create_textarea: (text, className) ->
      return new $viewWidgets.TextArea text, className
    create_button: (text, className) ->
      return new $viewWidgets.Button text, className
    create_textbox: (text, className='', placeholder='') ->
      return new $viewWidgets.TextBox text, className, placeholder
    create_label: (text, className) ->
      return new $viewWidgets.Label text, className


  viewRowDetailSkipLogic
