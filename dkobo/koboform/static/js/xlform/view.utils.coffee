@viewUtils = {}

viewUtils.makeEditable = (that, tagName, options) ->
  opts = 
    type: 'text'
    success: _.bind (uu, ent) ->
        @model.set("value", ent)
        null
      , that

  that.$el.find(tagName).editable _.extend(opts, options)

viewUtils.handleChange = (property, handler) ->
  do (property, handler) ->
    (model, value) -> 
      model.attributes[property] = if value then handler(value) else ""
      @render()