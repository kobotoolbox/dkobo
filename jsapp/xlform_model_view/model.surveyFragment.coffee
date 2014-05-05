define 'cs!xlform/model.surveyFragment', [
        'cs!xlform/model.base',
        'cs!xlform/model.row',
        ], (
            base,
            $row,
            )->

  surveyFragment = {}

  passFunctionToMetaModel = (obj, fname)->
    obj["__#{fname}"] = obj[fname]
    obj[fname] = (args...) -> obj._meta[fname].apply(obj._meta, args)

  class surveyFragment.SurveyFragment extends base.BaseCollection
    constructor: (a,b)->
      @rows = new $row.Rows([], _parent: @)
      @_meta = new Backbone.Model()
      passFunctionToMetaModel(@, "set")
      passFunctionToMetaModel(@, "get")
      passFunctionToMetaModel(@, "on")
      passFunctionToMetaModel(@, "trigger")
      super(a,b)
    _validate: -> true
    forEachRow: (cb, ctx={})->
      ctx.includeErrors ?= false
      @rows.each (r, index, list)->
        # if r instanceof XLF.SurveyDetail
        #   ``
        # else if !ctx.includeErrors && r instanceof row.RowError
        #   ``
        # else if r instanceof group.Group
        #   cb(r.groupStart())
        #   r.forEachRow(cb, ctx)
        #   cb(r.groupEnd())
        #   ``
        # else
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

  surveyFragment
