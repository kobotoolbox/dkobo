###
License: BSD 2-clause License (From http://github.com/dorey/xlform-builder/LICENSE.md)

Copyright (c) 2013, Alex Dorey
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list
    of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this
    list of conditions and the following disclaimer in the documentation and/or other
    materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.
###

###
Refactoring to consider:
------------------------
SurveyFragment extends Backbone.Collection (to get rid of @rows)
Get rid of XLF.Options
Get rid of XLF.ChoiceLists (?)
Get rid of XLF.SurveyDetails ( maybe ?)
Add "popover text" (or something similar) to XLF.defaultsForType
###

_.extend Backbone.Model.prototype, Backbone.Validation.mixin
###
@XLF holds much of the models/collections of the XL(s)Form survey
representation in the browser.
###
@XLF = {}

# @log function for debugging
@log = (args...)-> console?.log?.apply console, args

###
BaseCollection
###
class BaseCollection extends Backbone.Collection
  constructor: (arg, opts)->
    if "object" is typeof arg and "_parent" of arg
      @_parent = arg._parent
      delete arg._parent
    super(arg, opts)

  getSurvey: ->
    parent = @_parent
    while parent
      if parent._parent
        parent = parent._parent
      else
        return parent

###
XLF.Survey and associated Backbone Model
and Collection definitions
###
class BaseModel extends Backbone.Model
  constructor: (arg, opts)->
    if "object" is typeof arg and "_parent" of arg
      @_parent = arg._parent
      delete arg._parent
    super arg, opts

  parse: ->
  linkUp: ->

  getValue: (what)->
    if what then @get(what).getValue() else @get("value")

  getSurvey: ->
    parent = @_parent
    while parent
      if parent._parent
        parent = parent._parent
      else
        return parent

class SurveyFragment extends BaseModel
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

  getNames: () ->
    names = []
    @forEachRow (row) ->
      name = row.getValue("name")
      names.push(name)  if name
    names

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
    r._parent = @
    @rows.add r, opts

###
XLF...
  "Survey",
###

class XLF.Survey extends SurveyFragment
  initialize: (options={})->
    @rows = new XLF.Rows()
    @settings = new XLF.Settings(options.settings)
    if (sname = @settings.get("name"))
      @set("name", sname)
    @newRowDetails = options.newRowDetails || XLF.newRowDetails
    @defaultsForType = options.defaultsForType || XLF.defaultsForType
    @surveyDetails = new XLF.SurveyDetails().loadSchema(options.surveyDetailsSchema || XLF.surveyDetailSchema)
    passedChoices = options.choices || []
    @choices = do ->
      choices = new XLF.ChoiceLists()
      tmp = {}
      choiceNames = []
      for choiceRow in passedChoices
        lName = choiceRow["list name"]
        unless tmp[lName]
          tmp[lName] = []
          choiceNames.push(lName)
        tmp[lName].push(choiceRow)
      for cn in choiceNames
        choices.add(name: cn, options: tmp[cn])
      choices
    if options.survey
      for r in options.survey
        r._parent = @
        if r.type in XLF.surveyDetailSchema.typeList()
          @surveyDetails.importDetail(r)
        else if r.type in ["begin group", "begin repeat", "end group", "end repeat"]
          #noop, for now.
        else
          @rows.add r, collection: @rows, silent: true
    else
      @surveyDetails.importDefaults()
    @rows.invoke('linkUp')

  toCsvJson: ()->
    # build an object that can be easily passed to the "csv" library
    # to generate the XL(S)Form spreadsheet

    surveyCsvJson = do =>
      oCols = ["name", "type", "label"]
      oRows = []

      addRowToORows = (r)->
        colJson = r.toJSON()
        for own key, val of colJson when key not in oCols
          oCols.push key
        oRows.push colJson

      @forEachRow addRowToORows
      for sd in @surveyDetails.models when sd.get("value")
        addRowToORows(sd)

      columns: oCols
      rowObjects: oRows

    choicesCsvJson = do =>
      lists = []
      @forEachRow (r)->
        if (list = r.getList())
          lists.push(list)

      rows = []
      cols = ["list name", "name", "label"]
      for choiceList in lists
        choiceList.set("name", txtid(), silent: true)  unless choiceList.get("name")
        clName = choiceList.get("name")
        for option in choiceList.options.models
          rows.push _.extend {}, option.toJSON(), "list name": choiceList.get("name")

      columns: cols
      rowObjects: rows

    survey: surveyCsvJson
    choices: choicesCsvJson
    settings: @settings.toCsvJson()

  toCSV: ->
    sheeted = csv.sheeted()
    for shtName, content of @toCsvJson()
      sheeted.sheet shtName, csv(content)
    sheeted.toString()


###
XLF...
  "lookupRowType",
  "columnOrder",
  "Group",
  "Row",
  "Rows",
###

XLF.lookupRowType = do->
  typeLabels = [
    ["note", "Note", preventRequired: true],
    ["text", "Text"], # expects text
    ["integer", "Integer"], #e.g. 42
    ["decimal", "Decimal"], #e.g. 3.14
    ["geopoint", "Geopoint (GPS)"], # Can use satelite GPS coordinates
    ["image", "Image", isMedia: true], # Can use phone camera, for example
    ["barcode", "Barcode"], # Can scan a barcode using the phone camera
    ["date", "Date"], #e.g. (4 July, 1776)
    ["datetime", "Date and Time"], #e.g. (2012-Jan-4 3:04PM)
    ["audio", "Audio", isMedia: true], # Can use phone microphone to record audio
    ["video", "Video", isMedia: true], # Can use phone camera to record video
    ["calculate", "Calculate"],
    ["select_one", "Select", orOtherOption: true, specifyChoice: true],
    ["select_multiple", "Multiple choice", orOtherOption: true, specifyChoice: true]
  ]

  class Type
    constructor: ([@name, @label, opts])->
      opts = {}  unless opts
      _.extend(@, opts)

  types = (new Type(arr) for arr in typeLabels)

  exp = (typeId)->
    for tp in types when tp.name is typeId
      output = tp
    output

  exp.typeSelectList = do ->
    () -> types

  exp

XLF.columnOrder = do ->
  (key)->
    if -1 is XLF.columns.indexOf key
      XLF.columns.push(key)
    XLF.columns.indexOf key

class XLF.Group extends SurveyFragment
  initialize: ()->
    @set "type", "begin group"
    @rows = new XLF.Rows()
  groupStart: ->
    toJSON: => @attributes
    inGroupStart: true
  groupEnd: ->
    toJSON: ()-> type: "end group"

class XLF.Row extends BaseModel
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
        @set key, new XLF.RowDetail(key, val, @), {silent: true}

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
        matchedList = @_parent.choices.get(p2)
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
          clname = txtid()
          cl.set("name", clname, silent: true)
        @set("value", "#{@get('typeId')} #{clname}")

  getList: ->
    @get("type")?.get("list")

  setList: (list)->
    listToSet = @_parent.choices.get(list)
    unless listToSet
      @_parent.choices.add(list)
      listToSet = @_parent.choices.get(list)
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

class XLF.Rows extends BaseCollection
  model: (obj, ctxt)->
    type = obj?.type
    formSettingsTypes = do ->
      for key, val of XLF.defaultSurveyDetails
        val.asJson.type
    try
      if type in formSettingsTypes
        new XLF.SurveyDetail(obj)
      else if type is "group"
        new XLF.Group(obj)
      else
        new XLF.Row(obj)
    catch e
      new XLF.RowError(obj, error: e)
  comparator: (m)-> m.ordinal

class XLF.RowError extends BaseModel
  constructor: (obj, options)->
    console?.error("Error creating row: [#{options.error}]", obj)
    super(obj, options)

class XLF.RowDetail extends BaseModel
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

  constructor: (@key, valOrObj={}, @parentRow)->
    if @key of XLF.RowDetailMixins
      _.extend(@, XLF.RowDetailMixins[@key])
    super()
    vals2set = {}
    if _.isString(valOrObj)
      vals2set.value = valOrObj
    else if "value" of valOrObj
      _.extend vals2set, valOrObj
    else
      vals2set.value = valOrObj
    @set(vals2set)
    @_order = XLF.columnOrder(@key)
    @postInitialize()

  getSurvey: ()-> @parentRow.getSurvey()

  postInitialize: ()->
  initialize: ()->
    if @get("_hideUnlessChanged")
      @hidden = true
      @_oValue = @get("value")
      @on "change", ()->
        @hidden = @get("value") is @_oValue

    @on "change:value", (rd, val, ctxt)=>
      @parentRow.trigger "change", @key, val, ctxt
      @parentRow.trigger "detail-change", @key, val, ctxt
      @getSurvey().trigger "row-detail-change", @parentRow, @key, val, ctxt
    if @key is "type"
      @on "change:list", (rd, val, ctxt)=>
        @parentRow.trigger "change", @key, val, ctxt

class XLF.SkipLogicCriterion extends Backbone.Model
  @expressionValues:
    # key: ["expressionString", "Descriptive Label", additionalValueRequired]
    resp_equals:    ["=", "was", true]
    resp_notequals: ["!=", "was not", true]
    ans_notnull:    ["!= NULL", "was answered", false]
    ans_null:       ["= NULL", "was not answered", false]

  defaults:
    "expressionCode": "resp_equals"
  initialize: (atts, opts)->
    ###
    This criterion holds 3 attributes:
    1. The other question
    2. The expression
    3. (optional) The response text
    ###
    unless opts.silent
      @linkUp()

  linkUp: ()->
    survey = @get("parentRow").getSurvey()
    name = @get("name")
    if name
      question = survey.findRowByName(name)
      unless question
        throw new Error("Question with name `#{@get('name')}` not found")
      @set("question", question)

  serialize: ->
    if (question = @get("question"))
      questionName = question.getValue("name")
      if !questionName then return null
    else
      return null

    exCode = @get("expressionCode")
    unless exCode of @constructor.expressionValues
      throw new Error("ExpressionCode not recognized: #{exCode}")
    [exprStr, descLabel, addlReqs] = @constructor.expressionValues[exCode]
    wrappedCriterion = if addlReqs then ("'" + (@get('criterion') || '') + "'") else ""
    "${" + questionName + "} " + exprStr + " " + wrappedCriterion

class XLF.SkipLogicCollectionMeta extends Backbone.Model
  defaults:
    "delimSelect": "and"

class XLF.SkipLogicCollection extends BaseCollection
  model: XLF.SkipLogicCriterion
  constructor: (items, options={})->
    @rowDetail = options.rowDetail
    @parentRow = @rowDetail.parentRow
    @meta = new XLF.SkipLogicCollectionMeta()
    super(items, options)

  empty: ->
    @each (item)=> @remove(item)
    @
  serialize: ->
    joiners = {'or': " or ", 'and': " and "}
    joiner = @meta.get("delimSelect")
    throw new Error("Joiner not recognized: #{joiner}")  unless joiner of joiners
    _.compact(@map((item)=> item.serialize())).join(joiners[joiner])

# To be extended ontop of a RowDetail when the key matches
# the attribute in XLF.RowDetailMixin
SkipLogicDetailMixin =
  getValue: ()->
    @serialize()

  postInitialize: ()->
    @skipLogicCollection = new XLF.SkipLogicCollection([], rowDetail: @)
    @parse()

  serialize: ()->
    # @hidden = false
    # note: reimplement "hidden" if response is invalid
    @skipLogicCollection.serialize()

  parse: ()->
    value = @get('value')
    @skipLogicCollection.meta.set("rawValue", value)
    try
      parsedValues = XLF.skipLogicParser(value)
      @skipLogicCollection.empty()
      @skipLogicCollection.parseable = true
      for crit in parsedValues.criteria
        @skipLogicCollection.add({
          name: crit.name
          parentRow: @parentRow
          expressionCode: crit.operator
          criterion: crit.response_value
        }, silent: true)
      if parsedValues.operator
        @skipLogicCollection.meta.set("delimSelect", parsedValues.operator.toLowerCase())
      ``
    catch e
      @skipLogicCollection.parseable = false

  linkUp: ->
    @skipLogicCollection.each (i)-> i.linkUp()

@XLF.RowDetailMixins =
  relevant: SkipLogicDetailMixin

###
XLF...
  "Option",
  "Options",

  "ChoiceList",
  "ChoiceLists",
###
class XLF.Option extends BaseModel
  idAttribute: "name"
  initialize: -> @unset("list name")
  destroy: ->
    log "destroy me", @
  list: -> @collection
  toJSON: ()->
    label = @get("label")
    name = @get("name") || XLF.sluggify(label)
    {name: name, label: label}

class XLF.Options extends BaseCollection
  model: XLF.Option

class XLF.ChoiceList extends BaseModel
  idAttribute: "name"
  constructor: (opts={}, context)->
    options = opts.options || []
    super name: opts.name, context
    @options = new XLF.Options(options || [])
    @options.parentList = @
  summaryObj: ->
    name: @get("name")
    options: @options.models.map("toJSON")

class XLF.ChoiceLists extends BaseCollection
  model: XLF.ChoiceList
  summaryObj: ()->
    out = {}
    for model in @models
      out[model.get("name")] = model.summaryObj()
    out

###
XLF...
  "createSurveyFromCsv"
###
XLF.createSurveyFromCsv = (csv_repr)->
  opts = {}
  $settings   = opts.settings || {}
  # $launchEditor = if "launchEditor" in opts then opts.launchEditor else true
  $elemWrap   = $(opts.elemWrap || '#main')
  $publishCb  = opts.publish || ->

  if csv_repr
    if opts.survey or opts.choices
      throw new XlformError """
      [csv_repr] will cause other options to be ignored: [survey, choices]
      """
    cobj = csv.sheeted(csv_repr)
    $survey = if (sht = cobj.sheet "survey") then sht.toObjects() else []
    $choices = if (sht = cobj.sheet "choices") then sht.toObjects() else []

    if (settingsSheet = cobj.sheet "settings")
      $settings = settingsSheet.toObjects()[0]
  else
    $survey   = opts.survey || []
    $choices  = opts.choices || []        # settings: $settings

  new XLF.Survey(survey: $survey, choices: $choices, settings: $settings)


###
XLF...
  "SurveyDetail",
  "SurveyDetails"
  "Settings",
###
class XLF.SurveyDetail extends BaseModel
  idAttribute: "name"
  toJSON: ()->
    if @get("value")
      nameSlashType = @get("name")
      name: nameSlashType
      type: nameSlashType
    else
      false

class XLF.SurveyDetails extends BaseCollection
  model: XLF.SurveyDetail
  loadSchema: (schema)->
    throw new Error("Schema must be a Backbone.Collection")  unless schema instanceof Backbone.Collection
    for item in schema.models
      @add(new XLF.SurveyDetail(item._forSurvey()))
    @_schema = schema

    # we could prevent future changes to the schema...
    @add = @loadSchema = ()-> throw new Error("New survey details must be added to the schema")
    @
  importDefaults: ()->
    for item in @_schema.models
      relevantDetail = @get(item.get("name"))
      relevantDetail.set("value", item.get("default"))
    ``
  importDetail: (detail)->
    # For now, every detail which is presented is given a boolean value set to true
    if (dtobj = @get(detail.type))
      dtobj.set("value", true)
    else
      throw new Error("SurveyDetail `#{key}` not loaded from schema. [Aliases have not been implemented]")

class XLF.Settings extends BaseModel
  validation:
    form_title:
      required: true
      invalidChars: '`'
    form_id:
      required: true
      invalidChars: '`'
  defaults:
    form_title: "New survey"
    form_id: "new_survey"
  toCsvJson: ->
    columns = _.keys(@attributes)
    rowObjects = [@toJSON()]

    columns: columns
    rowObjects: rowObjects

###
misc helper methods
###
txtid = ()->
  # a is text
  # b is numeric or text
  # c is mishmash
  o = 'AAnCAnn'.replace /[AaCn]/g, (c)->
    randChar= ()->
      charI = Math.floor(Math.random()*52)
      charI += (if charI <= 25 then 65 else 71)
      String.fromCharCode charI

    r = Math.random()
    if c is 'a'
      randChar()
    else if c is 'A'
      String.fromCharCode 65+(r*26|0)
    else if c is 'C'
      newI = Math.floor(r*62)
      if newI > 52 then (newI - 52) else randChar()
    else if c is 'n'
      Math.floor(r*10)
  o.toLowerCase()

###
XLF.columns is used to determine the order that the elements
are added into the page and the final CSV.
###
XLF.columns = ["type", "name", "label", "hint", "required", "relevant", "constraint"]

###
XLF.newRowDetails are the default values that are assigned to a new
row when it is created.
###
XLF.newRowDetails =
  name:
    value: txtid
    randomId: true
  label:
    value: "new question"
  type:
    value: "text"
  hint:
    value: ""
    _hideUnlessChanged: true
  required:
    value: false
    _hideUnlessChanged: true
  relevant:
    value: ""
    _hideUnlessChanged: true
  constraint:
    value: ""
    _hideUnlessChanged: true

XLF.defaultsForType =
  geopoint:
    label:
      value: "Record your current location"
  image:
    label:
      value: "Point and shoot! Use the camera to take a photo"
  video:
    label:
      value: "Use the camera to record a video"
  audio:
    label:
      value: "Use the camera's microphone to record a sound"
  note:
    label:
      value: "This note can be read out loud"
  integer:
    label:
      value: "Enter a number"
  barcode:
    hint:
      value: "Use the camera to scan a barcode"
  decimal:
    label:
      value: "Enter a number"
  date:
    label:
      value: "Enter a date"
  datetime:
    label:
      value: "Enter a date and time"

