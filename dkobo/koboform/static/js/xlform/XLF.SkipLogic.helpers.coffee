class XLF.SkipLogicPresenter
  change_question: (question_name) ->
    @model.change_question question_name

    @question = @builder.survey.findRowByName question_name
    question_type = question_types[@question.getType()] || question_types['default']

    operator_type_id = @view.$operator_picker.val() || question_type.operators[0]

    negated = false
    if operator_type_id < 0
      negated = true
      operator_type_id = operator_type_id * -1

    @builder.operator_type = operator_type = operator_types[operator_type_id - 1]


    @view.change_operator @builder.build_operator_view question_type
    @view.operator_picker_view.fill_value @model.get('operator').get_value()

    if @view.$operator_picker.val() != @model.get('operator').get_value()

      @model.change_operator @builder.build_operator_model(question_type, operator_type, operator_type.symbol[operator_type.parser_name[+negated]])

    @builder.question_type = question_type

    @view.change_response @builder.build_response_view @question, question_type, operator_type
    @view.response_value_view.fill_value @model.get('response_value')
    @model.set('response_value', @view.$response_value.val())


  change_operator: (operator_id) ->
    negated = false
    if operator_id < 0
      negated = true
      operator_id = operator_id * -1

    @builder.operator_type = operator_type = operator_types[operator_id - 1]

    @model.change_operator @builder.build_operator_model(@builder.question_type, operator_type, operator_type.symbol[operator_type.parser_name[+negated]])

    @view.change_response @builder.build_response_view @question, @builder.question_type, operator_type
    @view.response_value_view.fill_value @model.get('response_value')
    @model.set('response_value', @view.$response_value.val())

  change_response: (response_text) ->
    @model.set('response_value', response_text)
  constructor: (@model, @view, @builder) ->
    @view.presenter = @
    @question = @builder.survey.findRowByName @model.get('question_name')
  render: (destination) ->
    @view.render().attach_to(destination)
    @view.question_picker_view.fill_value(@model.get('question_name'))
    @view.operator_picker_view.fill_value(@model.get('operator').get_value())
    @view.response_value_view.fill_value(@model.get('response_value'))
  serialize: () ->
    @model.serialize()

class XLF.SkipLogicCriterionBuilderFacade
  determine_criterion_delimiter_visibility: () ->
    if @presenters.length < 2
      @$criterion_delimiter.hide()
    else
      @$criterion_delimiter.show()
  render: (destination) ->
    @view.render().attach_to destination
    @$criterion_delimiter = @view.$(".skiplogic__delimselect")

    @determine_criterion_delimiter_visibility()

    @destination = @view.$('.skiplogic__criterialist')
    _.each @presenters, (presenter) =>
      presenter.render @destination
  serialize: () ->
    serialized = _.map @presenters, (presenter) ->
      presenter.serialize()
    serialized.join(' ' + @view.criterion_delimiter + ' ')
  add_empty: () ->
    presenter = @builder.build_empty_criterion_logic()
    presenter.render @destination
    @presenters.push presenter
    @determine_criterion_delimiter_visibility()
  remove: (id) ->
    _.each @presenters, (presenter, index) =>
      if presenter.model.cid == id
        @presenters.splice(index, 1)
  constructor: (@presenters, separator, @builder) ->
    @view = new XLF.SkipLogicCriterionBuilderView
    @view.criterion_delimiter = (separator || 'and').toLowerCase()
    @view.facade = @
  switch_editing_mode: () ->
    @builder.build_hand_code_criteria @serialize()

class XLF.SkipLogicHandCodeFacade
  render: (destination) ->
    @view.render().attach_to(destination)
    @view.$('textarea').val(@criteria)
  serialize: () ->
    @view.$('textarea').val()
  constructor: (@criteria, @builder) ->
    @view = new XLF.SkipLogicHandCodeView
  switch_editing_mode: () ->
    @builder.build_criterion_builder @serialize()

class XLF.SkipLogicBuilder
  build_hand_code_criteria: (criteria) ->
    new XLF.SkipLogicHandCodeFacade criteria, @
  build: () ->
    serialized_criteria = @current_question.get('relevant').get('value')

    @build_criterion_builder(serialized_criteria)

  build_criterion_builder: (serialized_criteria) ->
    if serialized_criteria == ''
      return new XLF.SkipLogicCriterionBuilderFacade [@build_empty_criterion_logic()], 'and', @
#    try
    parsed = XLF.skipLogicParser serialized_criteria

    if parsed.criteria.length > 1
      new XLF.SkipLogicCriterionBuilderFacade _.map(parsed.criteria, @build_criterion_logic), parsed.operator, @
    else
      new XLF.SkipLogicCriterionBuilderFacade [@build_criterion_logic parsed.criteria[0]], parsed.operator, @
#   catch e
#     @build_hand_code_criteria serialized_criteria

  build_operator_logic: (question_type, operator_type, criterion) =>
    return [@build_operator_model(question_type, operator_type, operator_type.symbol[criterion.operator]), @build_operator_view(question_type)]

  build_operator_model: (question_type, operator_type, symbol) ->
    return @model_factory.create_operator((if operator_type.type == 'existence' then 'existence' else question_type.equality_operator_type), symbol, operator_type.id)

  build_operator_view: (question_type) ->
    operators = _.filter(operator_types, (op_type) -> op_type.id in question_type.operators)
    @view_factory.create_operator_picker operators

  build_question_view: () ->
    @view_factory.create_question_picker @questions()

  build_response_view: (question, question_type, operator_type) ->
    responses = null

    if question_type.response_type == 'dropdown'
      responses = question.getList().options

    response_type = if operator_type.response_type? then operator_type.response_type else question_type.response_type

    @view_factory.create_response_value_view[response_type](responses)

  build_criterion_logic: (criterion) =>
    @operator_type = _.find operator_types, (op_type) ->
        criterion.operator in op_type.parser_name

    question = @survey.findRowByName criterion.name
    @question_type = question_types[question.getType()] || question_types['default']

    [operator_model, operator_picker_view] = @build_operator_logic @question_type, @operator_type, criterion

    criterion_model = @model_factory.create_criterion_model(
      criterion.name, criterion.response_value || '', operator_model)

    question_picker_view = @build_question_view()

    response_value_view = @build_response_view question, @question_type, @operator_type

    criterion_view = @view_factory.create_criterion_view question_picker_view, operator_picker_view, response_value_view
    criterion_view.model = criterion_model

    new XLF.SkipLogicPresenter(criterion_model, criterion_view, @)

  build_empty_criterion_logic: () =>
    criterion_model = @model_factory.create_criterion_model('', '', @model_factory.create_operator('empty'))

    question_picker_view = @build_question_view()


    criterion_view = @view_factory.create_criterion_view question_picker_view, @view_factory.create_operator_picker([]), @view_factory.create_response_value_view['empty']()
    criterion_view.model = criterion_model

    new XLF.SkipLogicPresenter(criterion_model, criterion_view, @)

  questions: () ->
    questions = []
    limit = false

    non_selectable = ['datetime', 'time', 'note', 'calculate']

    @survey.forEachRow (question) =>
      limit = limit || question is @current_question
      if !limit && question.getType() not in non_selectable
        questions.push question

    questions

  constructor: (@model_factory, @view_factory, @survey, @current_question) ->


question_types =
  default:
    operators: [1, 2]
    equality_operator_type: 'text'
    response_type: 'text'
  select_one:
    operators: [1, 2]
    equality_operator_type: 'text'
    response_type: 'dropdown'
  select_multiple:
    operators: [1, 2]
    equality_operator_type: 'select_multiple'
    response_type: 'dropdown'

operator_types = [
  {
    id: 1
    type: 'existence'
    label: 'Was Answered'
    negated_label: 'Was not Answered'
    parser_name: ['ans_notnull','ans_null']
    symbol: {
      ans_notnull: '!=',
      ans_null: '='
    }
    response_type: 'empty'
  }
  {
    id: 2
    type: 'equality'
    label: 'Was'
    negated_label: 'Was not'
    parser_name: ['resp_equals', 'resp_notequals', 'multiplechoice_selected', 'multiplechoice_notselected']
    symbol: {
      resp_equals: '=',
      resp_notequals: '!=',
      multiplechoice_selected: '='
      multiplechoice_notselected: '!='
    }
  }
]