global = @

describe "modules have been loaded into karma", ->
  expect_defined = (obj, attribute, name=false)->
    it "[! #{name or attribute} ¡]", ->
      expect(_.keys(obj)).toContain(attribute)
      expect(attribute in _.keys(obj)).toBeTruthy()
      expect(obj[attribute]).toBeDefined()

  describe "window .", ->
    expect_defined(global, "dkobo_xlform")
    expect_defined(global, "angular")
    expect_defined(global, "sinon")
    expect_defined(global, "jQuery")
    expect_defined(global, "_")

describe "dkobo_xlform .", ->
  expect_defined = (obj, attribute, name=false)->
    it "[! #{name or attribute} ¡]", ->
      expect(_.keys(obj)).toContain(attribute)
      expect(attribute in _.keys(obj)).toBeTruthy()
      expect(obj[attribute]).toBeDefined()

  xlf = dkobo_xlform

  # xlf.model
  expect_defined xlf, "model"
  describe "model .", ->

    # xlf.model.Survey
    expect_defined xlf.model, "Survey"

    describe "Survey .", ->
      expect_defined xlf.model.Survey, "load"

    # xlf.model.Row
    expect_defined xlf.model, "Row"
    # xlf.model.Rows
    expect_defined xlf.model, "Rows"
    # xlf.model.RowError
    expect_defined xlf.model, "RowError"

    # xlf.model.rowDetailsSkipLogic
    expect_defined xlf.model, "rowDetailsSkipLogic"

    # xlf.model.utils
    expect_defined xlf.model, "utils"
    describe "utils .", ->

      # xlf.model.utils.sluggify
      expect_defined xlf.model.utils, "sluggify"

      # xlf.model.utils.txtid
      expect_defined xlf.model.utils, "txtid"

      # xlf.model.utils.skipLogicParser
      expect_defined xlf.model.utils, "skipLogicParser"


  # xlf.view
  expect_defined xlf, "view"
  describe "view .", ->

    # xlf.view.SurveyApp
    expect_defined xlf.view, "SurveyApp"
    # xlf.view.QuestionApp
    expect_defined xlf.view, "QuestionApp"
    # xlf.view.utils
    expect_defined xlf.view, "utils"
    describe "utils .", ->
      # xlf.view.utils
      expect_defined xlf.view.utils, "reorderElemsByData"

  # xlf.helper
  expect_defined xlf, "helper"
  describe "helper .", ->

    # xlf.helper.skipLogic
    expect_defined xlf.helper, "skipLogic"
