class XLF.SkipLogicCriterion extends XLF.BaseModel
  @expressionValues:
    # key: ["expressionString", "Descriptive Label", additionalValueRequired]
    resp_equals:    ["=", "was", true]
    resp_notequals: ["!=", "was not", true]
    ans_notnull:    ["!= NULL", "was answered", false]
    ans_null:       ["= ''", "was not answered", false]
    multiplechoice_selected: [null, null, true]

  defaults:
    "expressionCode": "resp_equals"
  initialize: (atts, opts)->
    ###
    This criterion holds 3 attributes:
    1. The other question
    2. The expression
    3. (optional) The response text
    ###
    unless opts.silent
      @linkUp()

  linkUp: ()->
    survey = @getSurvey()
    name = @get("name")
    if name
      question = survey.findRowByName(name)
      unless question
        throw new Error("Question with name `#{@get('name')}` not found")
      @set("question", question)

  serialize: ->
    if (!(question = @get("question") && questionName = question.getValue("name")))
      return null

    if (question.getType() == 'select_one')
      @serialize_select_one()
    else
      exCode = @get("expressionCode")
      unless exCode of @constructor.expressionValues
        throw new Error("ExpressionCode not recognized: #{exCode}")
      [exprStr, descLabel, addlReqs] = @constructor.expressionValues[exCode]

      wrappedCriterion = if addlReqs then ("'" + (@get('criterion') || '') + "'") else ""

      "${" + questionName + "} " + exprStr + " " + wrappedCriterion
    serialize_select_one: ->
      criterionName = @get('criterionOption')?.get('name') or @get('criterion')

      if criterionName
        "selected('#{questionName}', '#{criterionName}')"
      else
        console?.error("Criterion not specified", @)
        null

class XLF.HandCodedSkipLogicCriterion extends XLF.SkipLogicCriterion
  initialize: (criteria) ->
    @set('value', criteria)
  serialize: () ->
    @get('value')
  linkUp: () ->

class XLF.SkipLogicCollectionMeta extends Backbone.Model
  defaults:
    "delimSelect": "and"
    "mode": "gui"

class XLF.SkipLogicCollection extends XLF.BaseCollection
  model: XLF.SkipLogicCriterion
  constructor: (items, options={})->
    @rowDetail = options.rowDetail
    @_parent = @rowDetail._parent
    @meta = new XLF.SkipLogicCollectionMeta()
    super(items, options)

  empty: ->
    @each (item)=> @remove(item)
    @
  serialize: ->
    joiners = {'or': " or ", 'and': " and "}
    joiner = @meta.get("delimSelect")
    throw new Error("Joiner not recognized: #{joiner}")  unless joiner of joiners
    _.compact(@map((item)=> item.serialize())).join(joiners[joiner])

  switchEditingMode: () ->
    if @meta.get("mode") == "gui"
      handcodedCriterion = new XLF.HandCodedSkipLogicCriterion(@serialize())
      @reset()
      @meta.set("mode", "handcode")
      @add(handcodedCriterion)
    else
      serialized = @serialize()
      XLF.parseHelper.parseSkipLogic(@, serialized, @_parent)
      if @parseable
        @meta.set("mode", "gui")
        @each((item) -> item.linkUp())
      else if serialized == ''
        @reset()
        @meta.set("mode", "gui")
      else
        @add(new XLF.HandCodedSkipLogicCriterion(serialized))
        alert("Could not parse: invalid / unsupported criteria")


class XLF.Model.SkipLogicFactory
  create_operator: (type, symbol, id) ->
    switch type
      when 'text' then operator = new XLF.TextValidationOperator symbol
      when 'basic' then operator = new XLF.BasicValidationOperator symbol
      when 'existence' then operator = new XLF.ExistenceValidationOperator symbol
      when 'select_multiple' then operator = new XLF.SelectMultipleValidationOperator symbol
      when 'empty' then return new XLF.EmptyOperator()
    operator.set 'id', id
    operator
  create_criterion_model: (question_name, response_value, operator) ->
    criterion = new XLF.SkipLogicCriterion()
    criterion.change_question question_name
    criterion.change_response response_value
    criterion.change_operator operator
    criterion

class XLF.SkipLogicCriterion extends XLF.BaseModel
  serialize: () ->
    return @get('operator').serialize @get('question_name'), @get('response_value')
  change_operator: (operator) ->
    @set('operator', operator)
  change_question: (value) ->
    @set('question_name', value)
  change_response: (value) ->
    @set('response_value', value)

class XLF.ValidationOperator extends XLF.BaseModel
  serialize: (question_name, response_value) ->
    throw new Error("Not Implemented")
  get_value: () ->
    val = ''
    if @get 'is_negated'
      val = '-'
    val + @get 'id'

class XLF.BasicValidationOperator extends XLF.ValidationOperator
  serialize: (question_name, response_value) ->
    return '${' + question_name + '} ' + @get('symbol') + ' ' + response_value
  constructor: (symbol) ->
    super()
    @set('symbol', symbol)
    @set('is_negated', symbol == '!=')

class XLF.ExistenceValidationOperator extends XLF.BasicValidationOperator
  serialize: (question_name) ->
    return super(question_name, "''")
  constructor: (operator) ->
    super(operator)
    @set('is_negated', operator == '=')

class XLF.TextValidationOperator extends XLF.BasicValidationOperator
  serialize: (question_name, response_value) ->
    return super(question_name, "'" + response_value + "'")

class XLF.EmptyOperator extends XLF.ValidationOperator
  constructor: () ->
    super()
    @set 'id', 0
    @set 'is_negated', false

class XLF.SelectMultipleValidationOperator extends XLF.ValidationOperator
  serialize: (question_name, response_value) ->
    selected = "selected(${" + question_name + "}, '" + response_value + "')"

    if @get('is_negated')
      return 'not(' + selected + ')'
    return selected
  constructor: (symbol) ->
    super()
    @set('symbol', symbol)
    @set('is_negated', symbol == '!=')