builder_controller_tests = ->
  beforeEach inject ($controller, $rootScope) ->
    test_helper.initializeController $controller, "Builder", $rootScope


  it "should initialize $scope and $rootScope correctly", ->
    expect(test_helper.$rs.activeTab).toBe "Forms"
    expect(test_helper.$scope.routeParams).toBe test_helper.hello

  describe "Location Change Confirmation", ->
    it "Should change location when user accepts confirmation", ->
      test_helper.miscUtils.confirm.returns true

      test_helper.$rs.deregisterLocationChangeStart = sinon.spy()
      test_helper.$rs.$broadcast "$locationChangeStart"

      expect(test_helper.$rs.deregisterLocationChangeStart).toHaveBeenCalledOnce()

    it "Should keep location when user rejects confirmation", ->
      test_helper.miscUtils.confirm.returns false
      test_helper.$rs.$broadcast "$locationChangeStart"

      expect(test_helper.miscUtils.preventDefault).toHaveBeenCalledOnce()


  describe "$scope.add_row_to_question_library", ->
    it "posts a survey object to the server", ->
      survey_stub =
        rows:
          add: sinon.spy()
        toCSV: sinon.stub()

      survey_factory_stub = sinon.stub(dkobo_xlform.model.Survey, "create")
      survey_factory_stub.returns survey_stub
      survey_stub.toCSV.returns "test survey"


      test_helper.$rs.add_row_to_question_library "test row"

      expect(test_helper.$api.questions.save).toHaveBeenCalledWith
        body: "test survey"
        asset_type: "question"

      expect(survey_stub.rows.add).toHaveBeenCalledWith "test row"
