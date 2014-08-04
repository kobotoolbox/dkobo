asset_editor_controller_tests = ->
  beforeEach inject(($controller, $rootScope) ->
    test_helper.initializeController $controller, "AssetEditor", $rootScope
  )

  it "initializes the scope correctly", ->
    expect(test_helper.$rs.activeTab).toBe "Question Library > Edit question"
