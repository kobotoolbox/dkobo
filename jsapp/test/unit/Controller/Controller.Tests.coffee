controller_tests = ->
  beforeEach ->
    sinon.stub(dkobo_xlform.view.SurveyApp, "create").returns render: ->

  afterEach ->
    dkobo_xlform.view.SurveyApp.create.restore()

  describe "Forms Controller", forms_controller_tests

  describe "Assets Controller", assets_controller_tests

  describe "Asset Editor Controller", asset_editor_controller_tests

  describe "Header Controller", header_controller_tests

  describe "Builder Controller", builder_controller_tests

  describe "Import Controller", import_controller_tests
