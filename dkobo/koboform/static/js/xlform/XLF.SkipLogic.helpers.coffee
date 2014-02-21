class XLF.SkipLogicBuilder
  build: () ->
    serialized_criteria = @current_question.get('relevant').get('value')

    parsed = XLF.skipLogicParser serialized_criteria

    negated_operator_pattern = /not/

    is_negated = (operator, operator_type) -> !!operator_type.parser_name.indexOf(operator)

    build_operator_logic = (criterion, question_type, operator_type, dispatcher) =>
      symbol = operator_type.symbol[!is_negated]

      operators = _.filter(operator_types, (op_type) -> op_type.id in question_type.operators)

      operator_picker_view = @view_factory.create_operator_picker operators, dispatcher

      if operator_type.type == 'existence'
        return [@model_factory.create_operator['existence'](symbol), operator_picker_view]
      else
        return [@model_factory.create_operator[question_type.equality_operator_type](symbol), operator_picker_view]
    build_criterion_logic = (criterion) =>
      operator_type = _.find operator_types, (op_type) ->
        criterion.operator in op_type.parser_name

      dispatcher = _.clone Backbone.Events

      question = @survey.findRowByName criterion.name
      question_type = question_types[question.getType()]

      [operator_model, operator_picker_view] = build_operator_logic criterion, question_type, operator_type, dispatcher

      criterion_model = @model_factory.create_criterion_model(
        criterion.name, criterion.response_value || '', operator_model)

      question_picker_view = @view_factory.create_question_picker @questions, dispatcher

      responses = null

      if question_type.response_type == 'dropdown'
        responses = question.getList().options

      response_type = if operator_type.response_type? then operator_type.response_type else question_type.response_type

      response_value_view = @view_factory.create_response_value_view[response_type](dispatcher, responses)

      criterion_view = @view_factory.create_criterion_view dispatcher, question_picker_view, operator_picker_view, response_value_view

      criterion_view.render().attach_to(@root_element)

      operator_picker_view.fill_value((is_negated(criterion.operator, operator_type) && '-' || '') + operator_type.id)

      dispatcher.on 'change:question', (value) ->
        criterion_model.change_question value

    if parsed.criteria.length > 1
      _.each parsed.criteria, build_criterion_logic
    else build_criterion_logic parsed.criteria[0]

  constructor: (@model_factory, @view_factory, @survey, @current_question, @root_element) ->
    @questions = []
    limit = false

    @survey.forEachRow (question) =>
      limit = limit || question is current_question
      if !limit
        @questions.push question


question_types =
  text:
    operators: [1, 2]
    equality_operator_type: 'text'
    response_type: 'text'

operator_types = [
  {
    id: 1
    type: 'existence'
    label: 'Was Answered'
    negated_label: 'Was not Answered'
    parser_name: ['ans_notnull','ans_null']
    symbol: {
      true: '!=',
      false: '='
    }
    response_type: 'empty'
  }
  {
    id: 2
    type: 'equality'
    label: 'Was'
    negated_label: 'Was not'
    parser_name: ['resp_equals', 'resp_notequals']
    symbol: {
      true: '=',
      false: '!='
    }
  }
]