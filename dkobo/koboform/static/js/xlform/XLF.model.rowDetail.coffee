class XLF.RowDetail extends XLF.BaseModel
  validation: () =>
    if @key == 'name'
      return value:
        unique: true
        required: true
    else if @key == 'label'
      return value:
        required: true
    {}
  idAttribute: "name"

  constructor: ({@key, value}, opts)->
    @_parent = opts._parent
    if @key of XLF.RowDetailMixins
      _.extend(@, XLF.RowDetailMixins[@key])
    super()
    vals2set = {}
    if _.isString(value) || _.isNumber(value)
      vals2set.value = value
    else if "value" of value
      _.extend vals2set, value
    else
      vals2set.value = value
    @set(vals2set)
    @_order = XLF.columnOrder(@key)
    @postInitialize()

  postInitialize: ()->
  initialize: ()->
    if @get("_hideUnlessChanged")
      @hidden = true
      @_oValue = @get("value")
      @on "change", ()->
        @hidden = @get("value") is @_oValue

    @on "change:value", (rd, val, ctxt)=>
      @_parent.trigger "change", @key, val, ctxt
      @_parent.trigger "detail-change", @key, val, ctxt
      @getSurvey().trigger "row-detail-change", @_parent, @key, val, ctxt
      XLF.dispatcher().trigger 'change:' + @key
    if @key is "type"
      @on "change:list", (rd, val, ctxt)=>
        @_parent.trigger "change", @key, val, ctxt

