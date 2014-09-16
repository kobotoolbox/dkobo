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
      if !options.settings
        @settings.enable_auto_name()

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
    insert_row: (row, index) ->
      @rows.add(row.toJSON(), at: index)
      new_row = @rows.at(index)
      if rowlist = new_row.getList()
        @choices.add(name: rowlist.get("name"), options: rowlist.options.toJSON())
      name_detail = new_row.get('name')
      name_detail.set 'value', name_detail.deduplicate(@)

    insertSurvey: (survey, index=-1)->
      index = @rows.length  if index is -1
      for row, row_i in survey.rows.models
        index_incr = index + row_i
        @insert_row row, index_incr
      ``
    toJSON: (stringify=false, spaces=4)->
      obj = {}
      choices = new $choices.ChoiceLists()
      obj.survey = do =>
        out = []
        fn = (r)->
          if 'getList' of r and (l = r.getList())
            choices.add(l)
          out.push r.toJSON2()
        @forEachRow fn
        out
      if choices.length > 0
        obj.choices = choices.summaryObj(true)
      if stringify
        JSON.stringify(obj, null, spaces)
      else
        obj
    getSurvey: -> @
    log: (opts={})->
      logFn = opts.log or (a...)-> console.log.apply(console, a)
      tabs = ['-']
      logr = (r)->
        if 'forEachRow' of r
          logFn tabs.join('').replace(/-/g, '='), r.get('label').get('value')
          tabs.push('-')
          r.forEachRow(logr, flat: true, includeGroups: true)
          tabs.pop()
        else
          logFn tabs.join(''), r.get('label').get('value')
      @forEachRow(logr, flat: true, includeGroups: true)
      ``
    summarize: ->
      rowCount = 0
      hasGps = false
      fn = (r)->
        if r.get('type').get('value') is 'geopoint'
          hasGps = true
        rowCount++
      @forEachRow(fn, includeGroups: false)

      # summaryObj
      rowCount: rowCount
      hasGps: hasGps
    _insertRowInPlace: (row, opts={})->
      if row._parent
        row.detach(silent: true)
      index = 0
      previous = opts.previous
      parent = opts.parent
      if previous
        parent = previous.parentRow()
        index = parent.rows.indexOf(previous) + 1
      if !parent
        parent = @
      parent.rows.add(row, at: index, silent: true)
      row._parent = parent.rows
      if opts.event
        parent.rows.trigger(opts.event)
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

  Survey.load = (csv_repr)->
    _deserialized = $inputDeserializer.deserialize csv_repr
    _parsed = $inputParser.parse _deserialized
    new Survey(_parsed)

  # Settings (assigned to each $survey.Survey instance)

  class Settings extends $base.BaseModel
    # validation:
    #   form_title:
    #     required: true
    #     invalidChars: '`'
    #   form_id:
    #     required: true
    #     invalidChars: '`'
    defaults:
      form_title: "New form"
      form_id: "new_form"
    toCsvJson: ->
      columns = _.keys(@attributes)
      rowObjects = [@toJSON()]

      columns: columns
      rowObjects: rowObjects
    enable_auto_name: () ->
      @auto_name = true

      @on 'change:form_id', () =>
        if @changing_form_title
          @changing_form_title = false
        else
          @auto_name = false

      @on 'change:form_title', (model, value) =>
        if @auto_name
          @changing_form_title = true
          @set 'form_id', $modelUtils.sluggifyLabel(value)



  Survey: Survey
  Settings: Settings
