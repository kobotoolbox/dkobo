class XLF.BaseCollection extends Backbone.Collection
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

###
XLF.Survey and associated Backbone Model
and Collection definitions
###
class XLF.BaseModel extends Backbone.Model
  constructor: (arg, opts)->
    if opts and "_parent" of opts
      @_parent = opts._parent
    else if "object" is typeof arg and "_parent" of arg
      @_parent = arg._parent
      delete arg._parent
    super(arg, opts)

  parse: ->
  linkUp: ->

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

passFunctionToMetaModel = (obj, fname)->
  obj["__#{fname}"] = obj[fname]
  obj[fname] = (args...) -> obj._meta[fname].apply(obj._meta, args)

class XLF.SurveyFragment extends XLF.BaseCollection
  constructor: (a,b)->
    @rows = new XLF.Rows([], _parent: @)
    @_meta = new Backbone.Model()
    passFunctionToMetaModel(@, "set")
    passFunctionToMetaModel(@, "get")
    passFunctionToMetaModel(@, "on")
    passFunctionToMetaModel(@, "trigger")
    super(a,b)

  _validate: -> true

  forEachRow: (cb, ctx={})->
    @rows.each (r, index, list)->
      if r instanceof XLF.SurveyDetail
        ``
      else if r instanceof XLF.RowError
        ``
      else if r instanceof XLF.Group
        context = {}

        cb(r.groupStart())
        r.forEachRow(cb, context)
        cb(r.groupEnd())
        ``
      else
        cb(r)

  forEachRowIncludingErrors: (cb)->
    ###
    This is similar to forEachRow but it also iterates on
    "RowError"s. We probably should merge this in with
    forEachRow and allow optional parameters to specify
    what fields should be iterated on.
    ###
    @rows.each (r, index, list)->
      if r instanceof XLF.SurveyDetail
        ``
      else if r instanceof XLF.Group
        context = {}

        cb(r.groupStart())
        r.forEachRowIncludingErrors(cb, context)
        cb(r.groupEnd())
        ``
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
