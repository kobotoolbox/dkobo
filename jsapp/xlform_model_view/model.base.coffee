define 'cs!xlform/model.base', [
        'underscore',
        'backbone',
        'backbone-validation',
        'cs!xlform/view.utils',
        ], (
            _,
            Backbone,
            validation,
            $viewUtils,
            )->



  _.extend validation.validators, {
    invalidChars: (value, attr, customValue)->
      unless $viewUtils.Validator.__validators.invalidChars(value, customValue)
        "#{value} contains invalid characters";
      unique: (value, attr, customValue, model)->
        rows = model.getSurvey().rows.pluck(model.key)
        values = _.map(rows, (rd)-> rd.get('value'))
        unless $viewUtils.Validator.__validators.unique(value, values)
          "Question name isn't unique"
        else
          ``
    }

  _.extend(Backbone.Model.prototype, validation.mixin);

  # TODO: Extend Backbone Validation
  # _.extend Backbone.Model.prototype, Backbone.Validation.mixin

  base = {}
  class base.BaseCollection extends Backbone.Collection
    constructor: (arg, opts)->
      if arg and "_parent" of arg
        # temporary error, during transition
        throw new Error("_parent chould be assigned as property to 2nd argument to XLF.BaseCollection (not first)")
      @_parent = opts._parent  if opts and opts._parent
      super(arg, opts)

    getSurvey: ->
      parent = @_parent
      while parent._parent
        parent = parent._parent
      parent

  class base.BaseModel extends Backbone.Model
    constructor: (arg, opts)->
      if opts and "_parent" of opts
        @_parent = opts._parent
      else if "object" is typeof arg and "_parent" of arg
        @_parent = arg._parent
        delete arg._parent
      super(arg, opts)
    parse: ->
    linkUp: ->
    finalize: ->
    getValue: (what)->
      if what
        resp = @get(what)
        if resp
          resp = resp.getValue()
        else
          throw new Error("Could not get value")
      else
        resp = @get("value")
      resp
    getSurvey: ->
      parent = @_parent
      while parent._parent
        parent = parent._parent
      parent

  base
