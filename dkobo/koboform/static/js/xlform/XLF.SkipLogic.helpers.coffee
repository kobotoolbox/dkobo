class XLF.SkipLogicBuilder
  build: () ->
    serialized_criteria = @current_question.get('constraint').get('value')

    parsed = XLF.skipLogicParser serialized_criteria

    negated_operator_pattern = /not/

    build_operator_model = (criterion) =>
      operator_type = _.find operator_types, (op_type) ->
        criterion.operator in op_type.parser_name

      is_negated = negated_operator_pattern.test criterion.operator
      question = @survey.findRowByName criterion.name
      question_type = question_types[question.getType()]

      fn = @model_factory.create_operator[operator_type.type] || @model_factory.create_operator[question_type.equality_operator_type]

      fn(if is_negated then operator_type.negated_symbol else operator_type.symbol)

    if parse.criteria.length > 1
      _.each parsed.criteria, (criterion) =>
        dispatcher = _.clone Backbone.Events

        operator_model = build_operator_model criterion

        criterion_model = @modelFactory.create_criterion_model()

        dispatcher.on 'change:question', (value) ->
          criterion_model.set_question value

  constructor: (@model_factory, @view_factory, @survey, @current_question) ->
    @questions = []
    limit = false

    @survey.forEachRow (question) =>
      limit = limit || question is currentQuestion
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
    parser_name: ['ans_null', 'ans_notnull']
    symbol: '='
    negated_symbol: '!='
  }
  {
    id: 2
    type: 'equality'
    label: 'Was'
    negated_label: 'Was not'
    parser_name: ['resp_equals', 'resp_notequals']
    symbol: '='
    negated_symbol: '!='
  }
]