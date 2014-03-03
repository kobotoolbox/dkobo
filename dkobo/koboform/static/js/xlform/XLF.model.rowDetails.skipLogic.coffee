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
  create_criterion_model: (question_name, operator) ->
    criterion = new XLF.SkipLogicCriterion()
    criterion.change_question question_name
    criterion.change_operator operator
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
  change_operator: (operator) ->
    @set('operator', operator)
  change_question: (value) ->
    @set('question_name', value)
  change_response: (value) ->
    @get('response_value').set('value', value, validate: true)

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
