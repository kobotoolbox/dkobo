import_controller_tests = ->
  it "should initialize $scope and $rootScope correctly", inject(($controller, $rootScope) ->
    test_helper.initializeController $controller, "Import", $rootScope
    expect(test_helper.$scope.csrfToken).toBe "test token"
    expect(test_helper.$rs.canAddNew).toBe false
    expect(test_helper.$rs.activeTab).toBe "Import CSV"
  )
