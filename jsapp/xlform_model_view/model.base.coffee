define 'cs!xlform/model.base', [
        'underscore',
        'backbone',
        'backbone-validation',
        'cs!xlform/view.utils',
        'cs!xlform/model.configs',
        'cs!xlform/model.rowDetailMixins',
        ], (
            _,
            Backbone,
            validation,
            $viewUtils,
            $configs,
            $rowDetailMixins,
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
    get: (what)->
      super(what)
    getAttributeValue: (what, opts)->
      resp = @get(what)
      if resp
        if resp._hasLang()
          resp._translation(opts)
        else
          resp = resp._value()
      else
        throw new Error("Could not get value")

    getValue: (what)->
      if what
        throw new Error('detail.getValue(att) is deprecated: use detail.getAttributeValue(att)')
      @_value()

    setDetail: (what, value)->
      if value.constructor is base.RowDetail
        @set(what, value)
      else
        @set(what, base.createRowDetail({key: what, value: value}, {_parent: @}))
    parentRow: ->
      @_parent._parent
    precedingRow: ->
      ii = @_parent.models.indexOf(@)
      @_parent.at(ii-1)
    nextRow: ->
      ii = @_parent.models.indexOf(@)
      @_parent.at(ii+1)
    getSurvey: ->
      parent = @_parent
      if parent == null
        return null
      while parent._parent
        parent = parent._parent
      parent

  base.createRowDetail = (opts1, opts2)->
    unless opts1.key
      throw new Error('base.createRowDetail(params): params needs a key')
    multilang = 'hint label'.split(' ')
    nolang = 'name default type required constraint relevant'.split(' ')
    tmpkeys = ['_isRepeat']
    key = opts1.key

    if key in multilang
      new base.TranslatableRowDetail(opts1, opts2)
    else if key in nolang
      new base.RowDetail(opts1, opts2)
    else
      unless key in tmpkeys
        log "Key Translatability unkown", key
      new base.RowDetail(opts1, opts2)

  class base.RowDetail extends base.BaseModel
    idAttribute: "name"
    _hasLang: -> @constructor.hasLanguage
    @hasLanguage: false
    validation: () =>
      if @key == 'name'
        return value:
          unique: true
          required: true
      else if @key == 'calculation'
        return value:
          required: true
      else if @key == 'label' && @_parent.constructor.key != 'group'
        return value:
          required: true
      {}

    get: (what)->
      if what is 'value'
        errmsg = "use _value() instead of get('value')"
        console?.error(errmsg)
        # throw new Error(errmsg)
        @_value()
      else
        super(what)

    _value: ()->
      return @attributes.value

    _translation: ()->
      throw new Error('Cannot Translate untranslatable rowDetail')

    constructor: ({@key, value}, opts)->
      @_parent = opts._parent
      if @key of $rowDetailMixins
        _.extend(@, $rowDetailMixins[@key])
      super()
      # We should consider pulling the value from the CSV at this stage
      # depending on the question type. truthy-CSV values should be set here
      # In the quick fix, this is done in the view for 'required' rowDetails
      # (grep: XLF.configs.truthyValues)

      if value not in [undefined, false, null]
        vals2set = {}
        if _.isString(value) || _.isNumber(value)
          vals2set.value = value
        else if _.isObject(value) and "value" of value
          _.extend vals2set, value
        else
          vals2set.value = value
        @set(vals2set)
      @_order = $configs.columnOrder(@key)
      @postInitialize()

    postInitialize: ()->
    initialize: ()->
      # todo: change "_hideUnlessChanged" to describe something about the form, not the representation of the form.
      # E.g. undefinedUnlessChanged or definedIffChanged
      if @get("_hideUnlessChanged")
        @hidden = true
        @_oValue = @_value()
        @on "change", ()->
          @hidden = @_value() is @_oValue

      @on "change:value", (rd, val, ctxt)=>
        @_parent.trigger "change", @key, val, ctxt
        @_parent.trigger "detail-change", @key, val, ctxt
        @getSurvey().trigger "row-detail-change", @_parent, @key, val, ctxt
      if @key is "type"
        @on "change:list", (rd, val, ctxt)=>
          @_parent.trigger "change", @key, val, ctxt

  class base.TranslatableRowDetail extends base.RowDetail
    @hasLanguage: true
    _translation: (opts={})->
      unless opts.language
        throw new Error('TranslatableRowDetail receives a language as a parameter')
      # to be replaced with someting that looks up translation
      @attributes.value

    _value: (opts={})->
      if !opts.language
        throw new Error("Language not specified")
      super()

  base
