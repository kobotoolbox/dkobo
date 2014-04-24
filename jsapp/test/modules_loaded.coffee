global = @

describe "modules have been loaded into karma", ->
  expect_defined = (attribute, name=false)->
    it "including #{name or attribute}", ->
      expect(global[attribute]).toBeDefined()

  expect_defined("dkobo_xlform")
  expect_defined("angular")
  expect_defined("sinon")
  expect_defined("_")

