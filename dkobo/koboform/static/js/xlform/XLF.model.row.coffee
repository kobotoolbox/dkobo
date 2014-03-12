_determineConstructorByParams = (obj)->
  formSettingsTypes = do ->
    for key, val of XLF.defaultSurveyDetails
      val.asJson.type
  type = obj?.type
  if type in formSettingsTypes
    XLF.SurveyDetail
  else if type in XLF.aliases("group")
    XLF.RowError
  else
    XLF.Row

class XLF.Rows extends XLF.BaseCollection
  model: (obj, ctxt)->
    RowConstructor = _determineConstructorByParams(obj)
    try
      new RowConstructor(obj, _.extend({}, ctxt, _parent: ctxt.collection))
    catch e
      # Store exceptions in with the survey
      new XLF.RowError(obj, _.extend({}, ctxt, error: e, _parent: ctxt.collection))
  comparator: (m)-> m.ordinal

class XLF.Row extends XLF.BaseModel
  initialize: ->
    ###
    The best way to understand the @details collection is
    that it is a list of cells of the XLSForm spreadsheet.
    The column name is the "key" and the value is the "value".
    We opted for a collection (rather than just saving in the attributes of
    this model) because of the various state-related attributes
    that need to be saved for each cell and allowing room to grow.

    E.g.: {"key": "type", "value": "select_one from colors"}
          needs to keep track of how the value was built
    ###
    if @_parent
      defaultsUnlessDefined = @_parent.newRowDetails || XLF.newRowDetails
      defaultsForType = @_parent.defaultsForType || XLF.defaultsForType
    else
      console?.error "Row not linked to parent survey."
      defaultsUnlessDefined = XLF.newRowDetails
      defaultsForType = XLF.defaultsForType

    if @attributes.type and @attributes.type of defaultsForType
      curTypeDefaults = defaultsForType[@attributes.type]
    else
      curTypeDefaults = {}

    defaults = _.extend {}, defaultsUnlessDefined, curTypeDefaults

    for key, vals of defaults
      unless key of @attributes
        newVals = {}
        for vk, vv of vals
          newVals[vk] = if ("function" is typeof vv) then vv() else vv
        @set key, newVals


    for key, val of @attributes
      unless val instanceof XLF.RowDetail
        @set key, new XLF.RowDetail({key: key, value: val}, {_parent: @}), {silent: true}

    typeDetail = @get("type")
    tpVal = typeDetail.get("value")
    processType = (rd, newType, ctxt)=>
      # if value changes, it could be set from an initialization value
      # or it could be changed elsewhere.
      # we need to keep typeId, listName, and orOther in sync.
      [tpid, p2, p3] = newType.split(" ")
      typeDetail.set("typeId", tpid, silent: true)
      if p2
        typeDetail.set("listName", p2, silent: true)
        matchedList = @getSurvey().choices.get(p2)
        if matchedList
          typeDetail.set("list", matchedList)
      typeDetail.set("orOther", p3, silent: true)  if p3 is "or_other"
      if (rtp = XLF.lookupRowType(tpid))
        typeDetail.set("rowType", rtp, silent: true)
      else
        throw new Error "type `#{tpid}` not found"
    processType(typeDetail, tpVal, {})
    typeDetail.on "change:value", processType
    typeDetail.on "change:listName", (rd, listName, ctx)->
      rtp = typeDetail.get("rowType")
      typeStr = "#{typeDetail.get("typeId")}"
      if rtp.specifyChoice and listName
        typeStr += " #{listName}"
      if rtp.orOtherOption and typeDetail.get("orOther")
        typeStr += " or_other"
      typeDetail.set({value: typeStr}, silent: true)
    typeDetail.on "change:list", (rd, cl, ctx)->
      if typeDetail.get("rowType").specifyChoice
        clname = cl.get("name")
        unless clname
          clname = XLF.txtid()
          cl.set("name", clname, silent: true)
        @set("value", "#{@get('typeId')} #{clname}")

  finalize: ->
    existing_name = @get("name").getValue()
    unless existing_name
      names = []
      @getSurvey().forEachRow (r)->
        name = r.get("name").getValue()
        names.push(name)  if name
      label = @get("label").get("value")
      @get("name").set("value", XLF.sluggifyLabel(label, names))
    @

  get_type: ->
    XLF.question_types[@get('type').get('typeId')] || XLF.question_types['default']
  getList: ->
    @get("type")?.get("list")

  setList: (list)->
    listToSet = @getSurvey().choices.get(list)
    unless listToSet
      @getSurvey().choices.add(list)
      listToSet = @getSurvey().choices.get(list)
    throw new Error("List not found: #{list}")  unless listToSet
    @get("type").set("list", listToSet)
  parse: ->
    val.parse()  for key, val of @attributes

  linkUp: ->
    val.linkUp()  for key, val of @attributes

  attributesArray: ()->
    arr = ([k, v] for k, v of @attributes)
    arr.sort (a,b)-> if a[1]._order < b[1]._order then -1 else 1
    arr

  toJSON: ->
    outObj = {}
    for [key, val] in @attributesArray()
      result = @getValue(key)
      outObj[key] = result  unless @hidden
    outObj


class XLF.RowError extends XLF.BaseModel
  constructor: (obj, options)->
    @_error = options.error
    console?.error("Error creating row: [#{options.error}]", obj)
    super(obj, options)
  getValue: (what)->
    if what of @attributes
      @attributes[what]
    else
      "[error]"
