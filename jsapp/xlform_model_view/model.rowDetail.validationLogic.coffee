define 'cs!xlform/model.rowDetail.validationLogic', [
  'backbone',
  'xlform/model.rowDetails.skipLogic'
], (Backbone, $skipLogicModel) ->

  rowDetailValidationLogic = {}
  class rowDetailValidationLogic.ValidationLogicModelFactory extends $skipLogicModel.SkipLogicFactory
    create_operator: (type, symbol, id) ->
      operator = null
      switch type
        when 'text' then operator = new rowDetailValidationLogic.ValidationLogicTextOperator symbol
        when 'basic' then operator = new rowDetailValidationLogic.ValidationLogicBasicOperator symbol
        when 'existence' then operator = new rowDetailValidationLogic.ValidationLogicExistenceOperator symbol
        when 'select_multiple' then operator = new rowDetailValidationLogic.ValidationLogicSelectMultipleOperator symbol
        when 'empty' then return new $skipLogicModel.EmptyOperator()

      operator.set 'id', id
      return operator

  class rowDetailValidationLogic.ValidationLogicBasicOperator extends $skipLogicModel.SkipLogicOperator
    serialize: (question_name, response_value) ->
      return '. ' + this.get('symbol') + ' ' + response_value
  class rowDetailValidationLogic.ValidationLogicTextOperator extends rowDetailValidationLogic.ValidationLogicBasicOperator
    serialize: (question_name, response_value) ->
      return super '', ' ' + "'" + response_value.replace(/'/g, "\\'") + "'"
  class rowDetailValidationLogic.ValidationLogicExistenceOperator extends rowDetailValidationLogic.ValidationLogicBasicOperator
    serialize: () ->
      return super '', "''"
  class rowDetailValidationLogic.ValidationLogicSelectMultipleOperator extends $skipLogicModel.SelectMultipleSkipLogicOperator
    serialize: (question_name, response_value) ->
      selected = "selected(., '" + response_value + "')"
      if this.get 'is_negated'
          return 'not(' + selected + ')'
      return selected

  rowDetailValidationLogic
