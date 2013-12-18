@viewUtils = {}

viewUtils.makeEditable = (that, selector, property, transformFunction, options) ->
  if !transformFunction?
    transformFunction = (value) -> value
  else if _.isObject(transformFunction) && !_.isFunction(transformFunction)
    options = transformFunction
    transformFunction = (value) -> value

  if _.isObject(property)
    options = property
    property = 'value'
  else if _.isFunction property
    transformFunction = property
    property = value

  opts = 
    type: 'text'
    success: _.bind (uu, ent) ->
        ent = transformFunction ent
        (@model || @survey).set(property, ent)
        null
      , that

  that.$el.find(selector).editable _.extend(opts, options)

viewUtils.handleChange = (property, handler) ->
  (model, value) -> 
    model.set property, if value then handler(value) else ""
    @render()