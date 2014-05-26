define 'cs!xlform/model.survey', [
        'cs!xlform/model.base',
        'cs!xlform/model.choices',
        'cs!xlform/model.utils',
        'cs!xlform/model.configs',
        'cs!xlform/model.surveyFragment',
        'cs!xlform/model.surveyDetail',
        'cs!xlform/model.inputDeserializer',
        'cs!xlform/model.inputParser',
        'cs!xlform/csv',
        ], (
            $base,
            $choices,
            $modelUtils,
            $configs,
            $surveyFragment,
            $surveyDetail,
            $inputDeserializer,
            $inputParser,
            csv,
            )->

  class Survey extends $surveyFragment.SurveyFragment
    constructor: (options={}, addlOpts)->
      super()
      @_initialParams = options
      @settings = new Settings(options.settings, _parent: @)
      if (sname = @settings.get("name") or options.name)
        @set("name", sname)
      @newRowDetails = options.newRowDetails || $configs.newRowDetails
      @defaultsForType = options.defaultsForType || $configs.defaultsForType
      @surveyDetails = new $surveyDetail.SurveyDetails([], _parent: @).loadSchema(options.surveyDetailsSchema || $configs.surveyDetailSchema)
      passedChoices = options.choices || []
      @choices = new $choices.ChoiceLists([], _parent: @)
      $inputParser.loadChoiceLists(passedChoices, @choices)
      if options.survey
        for r in options.survey
          if r.type in $configs.surveyDetailSchema.typeList()
            @surveyDetails.importDetail(r)
          else
            @rows.add r, collection: @rows, silent: true, _parent: @rows
      else
        @surveyDetails.importDefaults()
      @rows.invoke('linkUp')

    @create: (options={}, addlOpts) ->
      return new Survey(options, addlOpts)

    insertSurvey: (survey, index=-1)->
      index = @rows.length  if index is -1
      for row, row_i in survey.rows.models
        if rowlist = row.getList()
          @choices.add(name: rowlist.get("name"), options: rowlist.options.toJSON())
        index_incr = index + row_i
        @rows.add(row.toJSON(), at: index_incr)
      ``

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

        @forEachRow addRowToORows, includeErrors: true, includeGroupEnds: true
        for sd in @surveyDetails.models when sd.get("value")
          addRowToORows(sd)

        columns: oCols
        rowObjects: oRows

      choicesCsvJson = do =>
        lists = new $choices.ChoiceLists()
        @forEachRow (r)->
          if 'getList' of r and (list = r.getList())
            lists.add list

        rows = []
        cols = ["list name", "name", "label"]
        for choiceList in lists.models
          choiceList.set("name", $modelUtils.txtid(), silent: true)  unless choiceList.get("name")
          choiceList.finalize()
          clAtts = choiceList.toJSON()
          clName = clAtts.name
          for option in clAtts.options
            rows.push _.extend {}, option, "list name": clName

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

    _addGroup: (opts)->
      opts._parent = @rows

      index = if ('index' of opts) then opts.index else -1
      delete opts.index

      unless '__rows' of opts
        opts.__rows = []

      for row in opts.__rows
        row.detach()

      grp = new $surveyFragment.Group(opts)
      @rows.add(grp)

    _allRows: ->
      rows = []
      @forEachRow ((r)-> rows.push(r)  if r.constructor.kls is "Row"), {}
      rows

    finalize: ->
      @forEachRow ((r)=> r.finalize()), includeGroups: true
      @

  Survey.load = (csv_repr)->
    _deserialized = $inputDeserializer.deserialize csv_repr
    _parsed = $inputParser.parse _deserialized
    new Survey(_parsed)

  # Settings (assigned to each $survey.Survey instance)

  class Settings extends $base.BaseModel
    validation:
      form_title:
        required: true
        invalidChars: '`'
      form_id:
        required: true
        invalidChars: '`'
    defaults:
      form_title: "New form"
      form_id: "new_form"
    toCsvJson: ->
      columns = _.keys(@attributes)
      rowObjects = [@toJSON()]

      columns: columns
      rowObjects: rowObjects

  Survey: Survey
  Settings: Settings
