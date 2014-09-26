global = if window? then window else process

define 'cs!xlform/model.row', [
        'underscore',
        'cs!xlform/model.base',
        'cs!xlform/model.configs',
        'cs!xlform/model.utils',
        'cs!xlform/model.surveyDetail',
        'cs!xlform/model.aliases',
        'cs!xlform/model.rowDetail',
        'cs!xlform/model.choices',
        'cs!xlform/mv.skipLogicHelpers',
        ], (
            _,
            base,
            $configs,
            $utils,
            $surveyDetail,
            $aliases,
            $rowDetail,
            $choices,
            $skipLogicHelpers,
            )->

  row = {}

  class row.BaseRow extends base.BaseModel
    @kls = "BaseRow"
    constructor: (attributes={}, options={})->
      for key, val of attributes when key is ""
        delete attributes[key]
      super(attributes, options)

    initialize: ->
      @convertAttributesToRowDetails()

    isError: -> false
    convertAttributesToRowDetails: ->
      for key, val of @attributes
        unless val instanceof $rowDetail.RowDetail
          @set key, new $rowDetail.RowDetail({key: key, value: val}, {_parent: @}), {silent: true}
    attributesArray: ()->
      arr = ([k, v] for k, v of @attributes)
      arr.sort (a,b)-> if a[1]._order < b[1]._order then -1 else 1
      arr
    isInGroup: ->
      @_parent?._parent?.constructor.kls is "Group"

    detach: (opts)->
      if @_parent
        @_parent.remove @, opts
        @_parent = null
      ``

    toJSON2: ->
      outObj = {}
      for [key, val] in @attributesArray()
        if key is 'type' and val.get('typeId') in ['select_one', 'select_multiple']
          result = {}
          result[val.get('typeId')] = val.get('listName')
        else
          result = @getValue(key)
        unless @hidden
          if _.isBoolean(result)
            outObj[key] = $configs.boolOutputs[if result then "true" else "false"]
          else if '' isnt result
            outObj[key] = result
      outObj

    toJSON: ->
      outObj = {}
      for [key, val] in @attributesArray()
        result = @getValue(key)
        unless @hidden
          if _.isBoolean(result)
            outObj[key] = $configs.boolOutputs[if result then "true" else "false"]
          else
            outObj[key] = result
      outObj

  class row.Row extends row.BaseRow
    @kls = "Row"
    initialize: ->
      ###
      The best way to understand the @details collection is
      that it is a list of cells of the XLSForm spreadsheet.
      The column name is the "key" and the value is the "value".
      We opted for a collection (rather than just saving in the attributes of
      this model) because of the various state-related attributes
      that need to be saved for each cell and this allows more room to grow.

      E.g.: {"key": "type", "value": "select_one colors"}
            needs to keep track of how the value was built
      ###
      if @_parent
        defaultsUnlessDefined = @_parent.newRowDetails || $configs.newRowDetails
        defaultsForType = @_parent.defaultsForType || $configs.defaultsForType
      else
        console?.error "Row not linked to parent survey."
        defaultsUnlessDefined = $configs.newRowDetails
        defaultsForType = $configs.defaultsForType

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

      @convertAttributesToRowDetails()

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
        if (rtp = $configs.lookupRowType(tpid))
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
            clname = $utils.txtid()
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
        @get("name").set("value", $utils.sluggifyLabel(label, names))
      @

    get_type: ->
      $skipLogicHelpers.question_types[@get('type').get('typeId')] || $skipLogicHelpers.question_types['default']

    _isSelectQuestion: ->
      # TODO [ald]: pull this from $aliases
      @get('type').get('typeId') in ['select_one', 'select_multiple']

    getList: ->
      _list = @get('type')?.get('list')
      if (not _list) and @_isSelectQuestion()
        _list = new $choices.ChoiceList()
        @setList(_list)
      _list

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

  class row.RowError extends row.BaseRow
    constructor: (obj, options)->
      @_error = options.error
      unless global.xlfHideWarnings
        console?.error("Error creating row: [#{options.error}]", obj)
      super(obj, options)
    isError: -> true
    getValue: (what)->
      if what of @attributes
        @attributes[what].get('value')
      else
        "[error]"

  row
