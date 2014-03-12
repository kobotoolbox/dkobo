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
    new XLF.SkipLogicCriterion(@, @survey)
  create_response_model: (type) ->
    model = null
    switch type
      when 'integer' then model = new XLF.Model.IntegerResponseModel
      when 'decimal' then model = new XLF.Model.DecimalResponseModel
      else model = new XLF.Model.ResponseModel
    model.set 'type', type
  constructor: (@survey) ->

class XLF.SkipLogicCriterion extends XLF.BaseModel
  serialize: () ->
    response_model = @get('response_value')
    if response_model.isValid() != false
      @_get_question().finalize()
      return @get('operator').serialize @_get_question().get('name').get('value'), response_model.get('value')
    else
      return ''
  _get_question: () ->
    @survey.rows.get(@get 'question_cid')
  change_question: (cid) ->
    old_question_type = @_get_question()?.get_type() || name: null
    @set('question_cid', cid)
    question_type = @_get_question().get_type()

    if @get('operator').get_id() not in question_type.operators
      @change_operator question_type.operators[0]
    else if old_question_type.name != question_type.name
      @change_operator @get('operator').get_value()

    if !@get('operator').get_type().response_type? && @_get_question().response_type != @get('response_value')?.get_type()
      @change_response @get('response_value').get 'value'
  change_operator: (operator) ->
    operator = +operator
    is_negated = false
    if operator < 0
      is_negated = true
      operator *=-1

    question_type = @_get_question().get_type()

    if !(operator in question_type.operators)
      return

    type = XLF.operator_types[operator - 1]
    symbol = type.symbol[type.parser_name[+is_negated]]
    operator_model = @factory.create_operator (if type.type == 'equality' then question_type.equality_operator_type else type.type), symbol, operator
    @set('operator', operator_model)

    if (type.response_type || question_type.response_type) != @get('response_value')?.get('type')
      @change_response @get('response_value')?.get('value') || ''

  get_correct_type: () ->
    @get('operator').get_type().response_type || @_get_question().get_type().response_type

  change_response: (value) ->
    response_model = @get('response_value')
    current_value = response_model?.get('value')
    if !response_model || response_model.get('type') != @get_correct_type()
      response_model = @factory.create_response_model @get_correct_type()
      @set('response_value', response_model)

    if @get_correct_type() == 'dropdown'
      choices = @_get_question().getList().options.models
      choice_names = _.map(choices, (model) -> model.get('name'))

      if value in choice_names
        response_model.set_value value
      else if current_value in choice_names
        response_model.set_value current_value
      else
        response_model.set_value choices[0].get('name')
    else
      response_model.set_value(value)
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
  get_type: () ->
    XLF.operator_types[@get('id') - 1]
  get_id: () ->
    @get 'id'

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

class XLF.Model.ResponseModel extends XLF.BaseModel
  get_type: () ->
    return @get('type')
  set_value: (value) ->
    @set('value', value, validate: true)

class XLF.Model.IntegerResponseModel extends XLF.Model.ResponseModel
  validation:
    value:
      pattern: 'digits'
      msg: 'Number must be integer'

class XLF.Model.DecimalResponseModel extends XLF.Model.ResponseModel
  validation:
    value:
      pattern: 'number'
      msg: 'Number must be decimal'
  set_value: (value) ->
    if typeof value == 'undefined'
      return
    value = value.replace(/\s/g, '')
    final_value = +value
    if isNaN(final_value)
      final_value = +(value.replace(',', '.'))
      if isNaN(final_value)
        if value.lastIndexOf(',') > value.lastIndexOf('.')
          final_value = +(value.replace('.', '').replace(',', '.'))
        else
          final_value = +(value.replace(',', ''))
    @set('value', final_value, validate: true)

class XLF.Model.DateResponseModel extends XLF.Model.ResponseModel
  validation:
    value:
      pattern: /date\(\'\d{4}-\d{2}-\d{2}\'\)/
  set_value: (value) ->
    if /^\d{4}-\d{2}-\d{2}$/.test(value)
      value = "date('" + value + "')"
    @set('value', value, validate: true)