define 'cs!xlform/model.surveyFragment', [
        'cs!xlform/model.base',
        'cs!xlform/model.row',
        'cs!xlform/model.aliases',
        'cs!xlform/model.configs',
        'backbone',
        ], (
            $base,
            $row,
            $aliases,
            $configs,
            Backbone,
            )->

  surveyFragment = {}

  passFunctionToMetaModel = (obj, fname)->
    obj["__#{fname}"] = obj[fname]
    obj[fname] = (args...) -> obj._meta[fname].apply(obj._meta, args)

  class surveyFragment.SurveyFragment extends $base.BaseCollection
    constructor: (a,b)->
      @rows = new Rows([], _parent: @)
      @_meta = new Backbone.Model()
      passFunctionToMetaModel(@, "set")
      passFunctionToMetaModel(@, "get")
      passFunctionToMetaModel(@, "on")
      passFunctionToMetaModel(@, "trigger")
      super(a,b)
    _validate: -> true
    linkUp: -> @invoke('linkUp')
    forEachRow: (cb, ctx={})->
      ctx.includeErrors ?= false
      @rows.each (r, index, list)->
        if typeof r.forEachRow is 'function'
          r.forEachRow cb, ctx
        else
          cb(r)
    getRowDescriptors: () ->
      descriptors = []
      @forEachRow (row) ->
        descriptor =
          label: row.getValue('label')
          name: row.getValue('name')
        descriptors.push(descriptor)
      descriptors
    findRowByName: (name)->
      match = false
      @forEachRow (row)->
        if row.getValue("name") is name
          match = row
        # maybe implement a way to bust out
        # of this loop with false response.
        !match
      match
    addRowAtIndex: (r, index)-> @addRow(r, at: index)
    addRow: (r, opts={})->
      @rows.add r, _.extend(opts, _parent: @rows)

  class Group extends $row.BaseRow
    @kls = "Group"
    @key = "group"
    constructor: (a,b)->
      __rows = a.__rows
      delete a.__rows
      @rows = new Rows([], _parent: @)
      super(a,b)
      @rows.add __rows
      @_groupOrRepeatKey = if @_isRepeat() then "repeat" else "group"

    initialize: ->
      @convertAttributesToRowDetails()

    _isRepeat: ()->
      !!(@get("type")?.get("value")?.match(/repeat/))

    forEachRow: (cb, ctxt={})->
      cb(@groupStart())  if ctxt.includeGroupEnds
      @rows.each (r, index, list)->
        if typeof r.forEachRow is 'function'
          r.forEachRow cb, ctxt
        else
          cb(r)
      cb(@groupEnd())  if ctxt.includeGroupEnds

    groupStart: ->
      group = @
      toJSON: ->
        out = {}
        for k, val of group.attributes
          out[k] = val.getValue()
        out.type = "begin #{group._groupOrRepeatKey}"
        out
    groupEnd: ->
      group = @
      toJSON: ()-> type: "end #{group._groupOrRepeatKey}"

  INVALID_TYPES_AT_THIS_STAGE = ['begin group', 'end group', 'begin repeat', 'end repeat']
  _determineConstructorByParams = (obj)->
    formSettingsTypes = do ->
      for key, val of $configs.defaultSurveyDetails
        val.asJson.type
    type = obj?.type
    if type in INVALID_TYPES_AT_THIS_STAGE
      # inputParser should have converted groups and repeats into a structure by this point
      throw new Error("Invalid type at this stage: #{type}")

    if type in formSettingsTypes
      $surveyDetail.SurveyDetail
    else if type in ['group', 'repeat']
      Group
    else
      $row.Row

  class Rows extends $base.BaseCollection
    model: (obj, ctxt)->
      RowConstructor = _determineConstructorByParams(obj)
      try
        new RowConstructor(obj, _.extend({}, ctxt, _parent: ctxt.collection))
      catch e
        # Store exceptions in with the survey
        new $row.RowError(obj, _.extend({}, ctxt, error: e, _parent: ctxt.collection))
    comparator: (m)-> m.ordinal

  surveyFragment
