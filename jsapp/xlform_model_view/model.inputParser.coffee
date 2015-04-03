define [
        'underscore',
        'cs!xlform/model.aliases',
        ], (
            _,
            $aliases,
            )->
  inputParser = {}

  class ParsedStruct
    constructor: (@type, @atts={})->
      @contents = []
    push: (item)->
      @contents.push(item)
      ``
    export: ->
      arr = []
      for item in @contents
        if item instanceof ParsedStruct
          item = item.export()
        arr.push(item)
      _.extend({}, @atts, {type: @type, __rows: arr})

  parseArr = (type='survey', sArr)->
    grpStack = [new ParsedStruct(type)]

    _pushGrp = (type='group', item)->
      grp = new ParsedStruct(type, item)
      _curGrp().push(grp)
      grpStack.push(grp)

    _popGrp = (closedByAtts, type)->
      _grp = grpStack.pop()
      if _grp.type isnt closedByAtts.type
        throw new Error("mismatched group/repeat tags")
      ``

    _curGrp = ->
      _l = grpStack.length
      if _l is 0
        throw new Error("unmatched group/repeat")
      grpStack[_l-1]

    for item in sArr
      _groupAtts = $aliases.q.testGroupOrRepeat(item.type)
      if _groupAtts
        if _groupAtts.begin
          _pushGrp(_groupAtts.type, item)
        else
          _popGrp(_groupAtts, item.type)
      else
        _curGrp().push(item)

    if grpStack.length isnt 1
      throw new Error("unclosed group/repeat")

    _curGrp().export().__rows

  inputParser.languages = do ->
    ###
    inputParser.languages helps transform advanced columns

    from:
      "col::lang1": "Translation1", "col::lang2": "Translation2".

    into:
      "col": { "lang1": "Translation1", "lang2": "Translation2" }

    The three parser types are:
      simple:
        - non-translatable column. fails if any '::'s exist
        - examples
          "name"
          "name::swahili" !!bad

      regular:
        - basic translatable column. fails only if 3 or more '::'s exist
        - examples
          "label"
          "label::english"
          "label::one::two" !!bad

      media:
        - expects 2 or 3 '::'s
        - examples
          "media" !! bad
          "media::image"
          "media::image::english"
    ###

    languages = {}

    languages.__parsers = {}

    # Define the 3 parser methods:
    languages.__parsers.media = (colName)->
      res = colName.split("::")
      if res.length > 3
        throw new Error("Media ColumnError: #{colName} has too many parse values (MAX 3)")
      if res.length < 2
        throw new Error("Media ColumnError: #{colName} has too few parse values (MIN 2)")

      column: res[0]
      language: if res.length is 3 then res[2] else ''
      mediaType: res[1]

    languages.__parsers.simple = (colName) ->
      if colName.match /::/
        throw new Error("Simple ColumnError: #{colName} cannot have multiple parse values-- #{JSON.stringify(colName.split('::'))}")

      column: colName

    languages.__parsers.regular = (colName, opts)->
      res = colName.split("::")

      if res.length > 2
        throw new Error("Regular ColumnError: '#{out.column}' cannot have more than two parse values-- #{JSON.stringify(res)}")

      column: res[0]
      language: if res.length is 2 then res[1] else ''

    # Define the object which determines which parser method should be used and
    # keeps track of columns which have been _parsed
    class ParseSorter
      constructor: (opts)->
        _fallback = opts.fallback || false
        delete opts.fallback
        _matches = opts
        @matches = []
        @_unmatched_columns = []

        for key, list of _matches
          fn = languages.__parsers[key]
          unless 'function' is typeof fn
            throw new Error('inputParser: parse method not found for #{key}')
          fn.fnId = key

          for item in list
            if _.isString(item)
              item = new RegExp("^#{item}$")
            @matches.push [item, fn]

        if _fallback
          @fallback = languages.__parsers[_fallback]
          @fallback.fnId = _fallback

        # an object to lookup previously matched columns
        @_handlers = {}
        @_parsed = {}

      _import_column: (col)->
        if col not of @_parsed
          handler = @_get_handler(col)
          @_parsed[col] = handler(col)
        ``

      _get_handler: (colName)->
        if colName not in @_handlers
          _found = false
          for [reg, fn] in @matches
            if colName.match(reg)
              _found = true
              @_handlers[colName] = fn

          if !_found and @fallback
            @_unmatched_columns.push colName
            @_handlers[colName] = @fallback
          else if !_found
            throw new Error("Cannot handle column #{colName} and no fallback parser set")

        @_handlers[colName]

      _compile_stats: ->
        @_stats =
          langs: []
          cols: []
          medias: []

        for key, val of @_parsed
          if 'language' of val and val.language not in @_stats.langs
            @_stats.langs.push(val.language)
          if 'column' of val and val.column not in @_stats.cols
            @_stats.cols.push(val.column)
          if 'media' of val and val.media not in @_stats.medias
            @_stats.medias.push(val.media)
        ``

      stats: ->
        @_compile_stats()
        @_stats

      langs: ->
        @stats().langs

    # a method to allow testing of the ParseSorter
    languages.__createParseSorter = (opts)->  new ParseSorter(opts)

    languages


  inputParser.parseArr = parseArr
  inputParser.parse = (o)->
    # sorts groups and repeats into groups and repeats (recreates the structure)
    if o.survey
      o.survey = parseArr('survey', o.survey)
    o

  inputParser.loadChoiceLists = (passedChoices, choices)->
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

  # groupByVisibility = (inp, hidden=[], remain=[])->
  #   hiddenTypes = $aliases.q.hiddenTypes()
  #   throw Error("inputParser.sortByVisibility requires an array")  unless _.isArray(inp)
  #   for row in inp
  #     dest = if row.type? in hiddenTypes then hidden else remain
  #   [hidden, inp]

  # inputParser.sortByVisibility = sortByVisibility
  inputParser
