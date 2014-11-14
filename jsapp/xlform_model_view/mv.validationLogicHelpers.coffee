define 'cs!xlform/mv.validationLogicHelpers', [
  'xlform/model.validationLogicParser',
  'cs!xlform/mv.skipLogicHelpers'
], ($validationLogicParser, $skipLogicHelpers) ->

  validationLogicHelpers = {}

  class validationLogicHelpers.ValidationLogicHelperFactory extends $skipLogicHelpers.SkipLogicHelperFactory
    create_presenter: (criterion_model, criterion_view, builder) ->
      return new validationLogicHelpers.ValidationLogicPresenter criterion_model, criterion_view, builder
    create_builder: () ->
      return new validationLogicHelpers.ValidationLogicBuilder @model_factory, @view_factory, @survey, @current_question, @

  class validationLogicHelpers.ValidationLogicPresenter extends $skipLogicHelpers.SkipLogicPresenter
    change_question: () -> return

  class validationLogicHelpers.ValidationLogicBuilder extends $skipLogicHelpers.SkipLogicBuilder
    parse_skip_logic_criteria: (criteria) ->
      return $validationLogicParser criteria
    build_criterion_logic: (criterion) =>
      @operator_type = _.find $skipLogicHelpers.operator_types, (op_type) ->
          criterion.operator in op_type.parser_name

      question = @current_question
      if !question
        return false

      @question_type = question.get_type()

      [operator_model, operator_picker_view] = @build_operator_logic @question_type, @operator_type, criterion

      criterion_model = @model_factory.create_criterion_model()
      criterion_model.set('operator', operator_model)
      criterion_model.change_question question.cid

      question_picker_view = @build_question_view()

      response_value_model = @build_response_model @question_type
      criterion_model.set('response_value', response_value_model)
      response_value_model.set('value', criterion.response_value)

      response_value_view = @build_response_view question, @question_type, @operator_type
      response_value_view.model = response_value_model

      criterion_view = @view_factory.create_criterion_view question_picker_view, operator_picker_view, response_value_view
      criterion_view.model = criterion_model

      new $skipLogicHelpers.SkipLogicPresenter(criterion_model, criterion_view, @)
    build_empty_criterion_logic: () ->
      criterion_model = @model_factory.create_criterion_model()
      criterion_model.set('operator', @model_factory.create_operator('empty'))
      criterion_model.change_question(@current_question.cid)
      question_picker_view = @build_question_view()
      question_type = @current_question.get_type()
      operator_type = $skipLogicHelpers.operator_types[question_type.operators[0]-1]

      operator_picker_view = @view_factory.create_operator_picker(_.map question_type.operators, (operator_id) ->
        $skipLogicHelpers.operator_types[operator_id - 1])
      criterion_view = @view_factory.create_criterion_view(
        question_picker_view,
        operator_picker_view,
        @build_response_view @current_question, question_type, operator_type
      )

      criterion_view.model = criterion_model

      @helper_factory.create_presenter criterion_model, criterion_view, @

    questions: () ->
      [@current_question]


  validationLogicHelpers