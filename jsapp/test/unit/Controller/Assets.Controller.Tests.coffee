assets_controller_tests = ->
  beforeEach inject(($controller, $rootScope) ->
    test_helper.initializeController $controller, "Assets", $rootScope
  )
  it "should initialize $scope and $rootScope correctly", () ->
    expect(test_helper.$rs.canAddNew).toBe true
    expect(test_helper.$rs.activeTab).toBe "Question Library"