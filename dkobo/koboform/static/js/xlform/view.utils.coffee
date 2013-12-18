@viewUtils = {}

viewUtils.makeEditable = (that, selector, property, options) ->
  if _.isObject(property)
    options = property
    property = 'value'

  #patch for SurveyApp
  #TODO make this method receive the model directly
  if !that.model?
    that.model = that.survey

  opts = 
    type: 'text'
    success: _.bind (uu, ent) ->
        @model.set(property, ent)
        null
      , that

  that.$el.find(selector).editable _.extend(opts, options)

viewUtils.handleChange = (property, handler) ->
  (model, value) -> 
    model.attributes[property] = if value then handler(value) else ""
    @render()