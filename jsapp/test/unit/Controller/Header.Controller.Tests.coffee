header_controller_tests = ->
  beforeEach inject(($controller, $rootScope) ->
    test_helper.initializeController $controller, "Header", $rootScope
  )
  it "should initialize $scope and $rootScope correctly", ->
    expect(test_helper.$scope.pageIconColor).toBe "teal"
    expect(test_helper.$scope.pageTitle).toBe "Forms"
    expect(test_helper.$scope.pageIcon).toBe "fa-file-text-o"
    expect(test_helper.$scope.topLevelMenuActive).toBe ""
    expect(test_helper.$rs.activeTab).toBe "Forms"

  describe "$scope.toggleTopMenu", ->
    it "should set the value of $scope.topLevelMenuActive to \"is-active\" when its value is an empty string", ->
      test_helper.$rs.topLevelMenuActive = ""
      test_helper.$scope.toggleTopMenu()
      expect(test_helper.$rs.topLevelMenuActive).toBe "is-active"

    it "should set the value of $scope.topLevelMenuActive to an empty string when its value is \"is-active\"", ->
      test_helper.$rs.topLevelMenuActive = "is-active"
      test_helper.$scope.toggleTopMenu()

      expect(test_helper.$rs.topLevelMenuActive).toBe ""
