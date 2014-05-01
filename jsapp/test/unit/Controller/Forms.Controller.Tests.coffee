forms_controller_tests = ->
  beforeEach inject(($controller, $rootScope) ->
    test_helper.initializeController $controller, "Forms", $rootScope
  )
  it "should initialize $rootScope and $scope correctly", ->
    expect(test_helper.$rs.canAddNew).toBe true
    expect(test_helper.$rs.activeTab).toBe "Forms"

  describe "$scope.deleteSurvey", ->
    _deleteSpy = null
    beforeEach () -> _deleteSpy = sinon.spy()
    it "should delete survey when user confirms deletion", ->
      test_helper.miscUtils.confirm.returns true
      test_helper.$scope.deleteSurvey
        id: 0
        $delete: _deleteSpy

      expect(_deleteSpy).toHaveBeenCalledOnce()

    it "should not delete survey when user cancels deletion", ->
      test_helper.miscUtils.confirm.returns false
      test_helper.$scope.deleteSurvey
        id: 0
        $delete: _deleteSpy

      expect(_deleteSpy).not.toHaveBeenCalled()


  describe "$scope.$watch(\"infoListItems\")", ->
    it "should set additionalClasses = content-centered when infoListItems is empty", ->
      test_helper.$rs.infoListItems = []
      test_helper.$rs.$apply()
      expect(test_helper.$rs.additionalClasses).toBe "content--centered"

    it "should set additionalClasses = \"\" when infoListItems contains elements", ->
      test_helper.$rs.infoListItems = [1]
      test_helper.$rs.$apply()
      expect(test_helper.$rs.additionalClasses).toBe ""
