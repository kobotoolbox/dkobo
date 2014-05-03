define [
        'cs!xlform/model.base',
        'cs!xlform/model.configs',
        'cs!xlform/model.rowDetailMixins',
        ], (
            base,
            $configs,
            $rowDetailMixins
            )->

  rowDetail = {}

  class rowDetail.RowDetail extends base.BaseModel
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
        else if "value" of value
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
        @_oValue = @get("value")
        @on "change", ()->
          @hidden = @get("value") is @_oValue

      @on "change:value", (rd, val, ctxt)=>
        @_parent.trigger "change", @key, val, ctxt
        @_parent.trigger "detail-change", @key, val, ctxt
        @getSurvey().trigger "row-detail-change", @_parent, @key, val, ctxt
      if @key is "type"
        @on "change:list", (rd, val, ctxt)=>
          @_parent.trigger "change", @key, val, ctxt

  rowDetail
