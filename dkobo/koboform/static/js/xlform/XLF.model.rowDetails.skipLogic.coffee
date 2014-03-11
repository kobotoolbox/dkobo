class XLF.Model.SkipLogicFactory
  create_operator: (type, symbol, id) ->
    switch type
      when 'text' then operator = new XLF.TextOperator symbol
      when 'basic' then operator = new XLF.SkipLogicOperator symbol
      when 'existence' then operator = new XLF.ExistenceSkipLogicOperator symbol
      when 'select_multiple' then operator = new XLF.SelectMultipleSkipLogicOperator symbol
      when 'empty' then return new XLF.EmptyOperator()
    operator.set 'id', id
    operator
  create_criterion_model: () ->
    criterion = new XLF.SkipLogicCriterion()
    criterion
  create_response_model: (type) ->
    switch type
      when 'integer' then new XLF.Model.IntegerResponseModel
      when 'decimal' then new XLF.Model.DecimalResponseModel
      else new XLF.Model.TextResponseModel

class XLF.SkipLogicCriterion extends XLF.BaseModel
  serialize: () ->
    response_model = @get('response_value')
    if response_model.isValid() != false
      return @get('operator').serialize @get('question_name'), response_model.get('value')
    else
      return ''
  _get_question: () ->
    @survey.rows.get(cid)
  change_question: (cid) ->
    @set('question_cid', cid)
    question_type = @_get_question().getType()

    if @get('operator').get_id() not in question_type.operators
      @change_operator question_type.operators[0]

    if !@get('operator').get_type().response_type? && @_get_question.response_type != @get('response_value').get_type()
      @change_response @get('response_value').get 'value'
  change_operator: (operator) ->
    is_negated = false
    if operator < 0
      is_negated = true
      operator *=-1

    if !(operator in @_get_question().operators)
      return

    type = XLF.operator_types[operator - 1]
    symbol = type.symbol[type.parser_name[+is_negated]]
    operator_model = @factory.create_operator type.type, symbol, operator
    @set('operator', operator_model)

    if type.response_type? && type.response_type != @get('response_value').get('type')
      @change_response @get('response_value').get('value')

  change_response: (value) ->
    response_model = @get('response_value')
    if response_model.get('type') != (@get('operator').get_type().response_type || @_get_question().get_type().response_type)
      response_model = @factory.create_response_model (@get('operator').get_type().response_type || @_get_question().get_type().response_type)
      @set('response_value', response_model)

    response_model.set('value', value, validate: true)
  constructor: (@factory, @survey) ->
    super()


class XLF.Operator extends XLF.BaseModel
  serialize: (question_name, response_value) ->
    throw new Error("Not Implemented")
  get_value: () ->
    val = ''
    if @get 'is_negated'
      val = '-'
    val + @get 'id'

class XLF.EmptyOperator extends XLF.Operator
  serialize: () -> ''
  constructor: () ->
    super()
    @set 'id', 0
    @set 'is_negated', false

class XLF.SkipLogicOperator extends XLF.Operator
  serialize: (question_name, response_value) ->
    return '${' + question_name + '} ' + @get('symbol') + ' ' + response_value
  constructor: (symbol) ->
    super()
    @set('symbol', symbol)
    @set('is_negated', symbol == '!=')

class XLF.TextOperator extends XLF.SkipLogicOperator
  serialize: (question_name, response_value) ->
    return super(question_name, "'" + response_value + "'")

class XLF.ExistenceSkipLogicOperator extends XLF.SkipLogicOperator
  serialize: (question_name) ->
    return super(question_name, "''")
  constructor: (operator) ->
    super(operator)
    @set('is_negated', operator == '=')

class XLF.SelectMultipleSkipLogicOperator extends XLF.SkipLogicOperator
  serialize: (question_name, response_value) ->
    selected = "selected(${" + question_name + "}, '" + response_value + "')"

    if @get('is_negated')
      return 'not(' + selected + ')'
    return selected

class XLF.Model.TextResponseModel extends XLF.BaseModel

class XLF.Model.IntegerResponseModel extends XLF.BaseModel
  validation:
    value:
      pattern: 'digits'
      msg: 'Number must be integer'

class XLF.Model.DecimalResponseModel extends XLF.BaseModel
  validation:
    value:
      pattern: 'number'
      msg: 'Number must be decimal'
