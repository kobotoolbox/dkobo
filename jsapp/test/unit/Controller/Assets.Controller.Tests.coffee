assets_controller_tests = ->
  beforeEach inject(($controller, $rootScope) ->
    test_helper.initializeController $controller, "Assets", $rootScope
  )
  it "should initialize $scope and $rootScope correctly", () ->
    expect(test_helper.$rs.canAddNew).toBe true
    expect(test_helper.$rs.activeTab).toBe "Question Library"

  describe "scope.watch select_all", ->
    it "sets selected properties to selected on all objects when select_all is true", ->
      test_helper.$rs.select_all = true
      test_helper.$rs.$apply()
      expect(test_helper.$rs.questions[0].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.questions[0].meta.additionalClasses).toBe "questions__question--selected"
      expect(test_helper.$rs.questions[1].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.questions[1].meta.additionalClasses).toBe "questions__question--selected"
      expect(test_helper.$rs.questions[2].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.questions[2].meta.additionalClasses).toBe "questions__question--selected"

    it "sets selected properties to deselected on all objects when select_all is false", ->
      test_helper.$rs.select_all = false
      test_helper.$rs.$apply()
      expect(test_helper.$rs.questions[0].meta.is_selected).toBeFalsy()
      expect(test_helper.$rs.questions[0].meta.additionalClasses).toBe ""
      expect(test_helper.$rs.questions[1].meta.is_selected).toBeFalsy()
      expect(test_helper.$rs.questions[1].meta.additionalClasses).toBe ""
      expect(test_helper.$rs.questions[2].meta.is_selected).toBeFalsy()
      expect(test_helper.$rs.questions[2].meta.additionalClasses).toBe ""

    it "no-ops when select_all is null", ->
      test_helper.$rs.select_all = true
      test_helper.$rs.$apply()
      test_helper.$rs.select_all = null
      test_helper.$rs.$apply()

      expect(test_helper.$rs.questions[0].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.questions[0].meta.additionalClasses).toBe "questions__question--selected"
      expect(test_helper.$rs.questions[1].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.questions[1].meta.additionalClasses).toBe "questions__question--selected"
      expect(test_helper.$rs.questions[2].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.questions[2].meta.additionalClasses).toBe "questions__question--selected"


  describe "$scope.delete_selected", ->
    it "deletes all selected items", ->
      test_helper.$rs.questions[1].meta.is_selected = true
      test_helper.miscUtils.confirm.returns true

      test_helper.$scope.delete_selected()
      expect(test_helper.$api.questions.remove).toHaveBeenCalledWith id: 2
      expect(test_helper.$rs.questions.length).toBe 2
      expect(test_helper.$rs.questions[0].id).toBe 1
      expect(test_helper.$rs.questions[1].id).toBe 3

    it "no ops when confirmation returns false", ->
      test_helper.$rs.questions[1].meta.is_selected = true
      test_helper.miscUtils.confirm.returns false

      test_helper.$scope.delete_selected()
      expect(test_helper.$rs.questions.length).toBe 3
      expect(test_helper.$rs.questions[0].id).toBe 1
      expect(test_helper.$rs.questions[1].id).toBe 2
      expect(test_helper.$rs.questions[2].id).toBe 3
