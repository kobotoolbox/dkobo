@viewUtils = {}

viewUtils.makeEditable = (that, model, selector, {property, transformFunction, options}) ->
  if !transformFunction?
    transformFunction = (value) -> value
  if !property?
    property = 'value'
  
  opts = 
    type: 'text'
    success: _.bind (uu, ent) ->
        ent = transformFunction ent
        model.set(property, ent, validate: true)
        if(model.validationError && model.validationError[property])
          return model.validationError[property]

        newValue: ent
      , that

  that.$el.find(selector).editable _.extend(opts, options)