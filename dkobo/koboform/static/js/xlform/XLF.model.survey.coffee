###
XLF.Survey
###

class XLF.Survey extends XLF.SurveyFragment
  constructor: (options={}, addlOpts)->
    super()
    @_initialParams = options
    @settings = new XLF.Settings(options.settings, _parent: @)
    if (sname = @settings.get("name") or options.name)
      @set("name", sname)
    @newRowDetails = options.newRowDetails || XLF.newRowDetails
    @defaultsForType = options.defaultsForType || XLF.defaultsForType
    @surveyDetails = new XLF.SurveyDetails([], _parent: @).loadSchema(options.surveyDetailsSchema || XLF.surveyDetailSchema)
    passedChoices = options.choices || []
    @choices = new XLF.ChoiceLists([], _parent: @)
    do (choices=@choices)->
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
    if options.survey
      for r in options.survey
        if r.type in XLF.surveyDetailSchema.typeList()
          @surveyDetails.importDetail(r)
        else
          @rows.add r, collection: @rows, silent: true, _parent: @rows
    else
      @surveyDetails.importDefaults()
    @rows.invoke('linkUp')

  toCsvJson: ()->
    # build an object that can be easily passed to the "csv" library
    # to generate the XL(S)Form spreadsheet

    @finalize()

    out = {}
    out.survey = do =>
      oCols = ["name", "type", "label"]
      oRows = []

      addRowToORows = (r)->
        colJson = r.toJSON()
        for own key, val of colJson when key not in oCols
          oCols.push key
        oRows.push colJson

      @forEachRowIncludingErrors addRowToORows
      for sd in @surveyDetails.models when sd.get("value")
        addRowToORows(sd)

      columns: oCols
      rowObjects: oRows

    choicesCsvJson = do =>
      lists = new XLF.ChoiceLists()
      @forEachRow (r)->
        if (list = r.getList())
          lists.add list

      rows = []
      cols = ["list name", "name", "label"]
      for choiceList in lists.models
        choiceList.set("name", XLF.txtid(), silent: true)  unless choiceList.get("name")
        clName = choiceList.get("name")
        for option in choiceList.options.models
          rows.push _.extend {}, option.toJSON(), "list name": choiceList.get("name")
      if rows.length > 0
        columns: cols
        rowObjects: rows
      else
        false

    out.choices = choicesCsvJson  if choicesCsvJson
    out.settings = @settings.toCsvJson()

    out

  toCSV: ->
    sheeted = csv.sheeted()
    for shtName, content of @toCsvJson()
      sheeted.sheet shtName, csv(content)
    sheeted.toString()

  finalize: ->
    @forEachRow (r)=> r.finalize()
    @

###
XLF.Settings (assigned to each XLF.Survey instance)
###

class XLF.Settings extends XLF.BaseModel
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
XLF.SurveyDetails (attached to a XLF.Survey instance) containing details such as
    start time, deviceid, (etc.)
###

class XLF.SurveyDetail extends XLF.BaseModel
  idAttribute: "name"
  toJSON: ()->
    if @get("value")
      nameSlashType = @get("name")
      name: nameSlashType
      type: nameSlashType
    else
      false

class XLF.SurveyDetails extends XLF.BaseCollection
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
