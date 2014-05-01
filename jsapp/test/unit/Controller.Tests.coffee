controller_tests = ->
  beforeEach ->
    sinon.stub(SurveyApp, "create").returns render: ->

  afterEach ->
    SurveyApp.create.restore()

  describe "Forms Controller", ->
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



  describe "Assets Controller", ->
    beforeEach inject(($controller, $rootScope) ->
      test_helper.initializeController $controller, "Assets", $rootScope
    )
    it "should initialize $scope and $rootScope correctly", () ->
      expect(test_helper.$rs.canAddNew).toBe true
      expect(test_helper.$rs.activeTab).toBe "Question Library"

    describe "$scope.toggle_response_list", ->
      it "shows responses when they are hidden", ->
        item =
          type: "select_one"
          meta:
            show_responses: false

        test_helper.$rs.toggle_response_list item
        expect(item.meta.question_type_class).toBe "question__type question__type--expanded"
        expect(item.meta.question_type_icon_class).toBe "question__type-icon question__type--expanded-icon"
        expect(item.meta.question_type_icon).toBe "fa fa-caret-down"
        expect(item.meta.show_responses).toBe true

      it "hides responses when they are visible", ->
        item =
          type: "select_one"
          meta:
            show_responses: true

        test_helper.$rs.toggle_response_list item
        expect(item.meta.show_responses).toBe false
        expect(item.meta.question_type_class).toBe "question__type"
        expect(item.meta.question_type_icon).toBe "fa fa-caret-right"
        expect(item.meta.question_type_icon_class).toBe "question__type-icon"


    describe "scope.toggle_selected", ->
      it "selects a deselected question", ->
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: false

        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[1].meta.question_class).toBe "questions__question questions__question--selected"

      it "deselects a selected question", ->
        test_helper.$rs.info_list_items[1].meta.is_selected = true
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: false

        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeFalsy()
        expect(test_helper.$rs.info_list_items[1].meta.question_class).toBe "questions__question"

      it "deselects all previously selected questions", ->
        test_helper.$rs.info_list_items[0].meta.is_selected = true
        test_helper.$rs.info_list_items[2].meta.is_selected = true
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: false

        expect(test_helper.$rs.info_list_items[0].meta.question_class).toBe "questions__question"
        expect(test_helper.$rs.info_list_items[0].meta.is_selected).toBeFalsy()
        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[2].meta.question_class).toBe "questions__question"
        expect(test_helper.$rs.info_list_items[2].meta.is_selected).toBeFalsy()

      it "keeps previously selected questions when ctrl is pressed", ->
        test_helper.$rs.info_list_items[0].meta.is_selected = true
        test_helper.$rs.info_list_items[2].meta.is_selected = true
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: true

        expect(test_helper.$rs.info_list_items[0].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[2].meta.is_selected).toBeTruthy()

      it "deselects all questions except clicked question when multiple questions selected, current question selected and ctrl isnt pressed", ->
        test_helper.$rs.info_list_items[0].meta.is_selected = true
        test_helper.$rs.info_list_items[1].meta.is_selected = true
        test_helper.$rs.info_list_items[2].meta.is_selected = true
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: false

        expect(test_helper.$rs.info_list_items[0].meta.is_selected).toBeFalsy()
        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[2].meta.is_selected).toBeFalsy()

      it "deselects a selected question when multiple questions selected and ctrl is pressed", ->
        test_helper.$rs.info_list_items[0].meta.is_selected = true
        test_helper.$rs.info_list_items[1].meta.is_selected = true
        test_helper.$rs.info_list_items[2].meta.is_selected = true
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: true

        expect(test_helper.$rs.info_list_items[0].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeFalsy()
        expect(test_helper.$rs.info_list_items[2].meta.is_selected).toBeTruthy()

      it "sets select_all switch when all questions selected", ->
        test_helper.$rs.info_list_items[0].meta.is_selected = true
        test_helper.$rs.info_list_items[2].meta.is_selected = true
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: true

        expect(test_helper.$rs.select_all).toBeTruthy()

      it "clears select_all switch when not all questions selected", ->
        test_helper.$rs.info_list_items[0].meta.is_selected = true
        test_helper.$rs.info_list_items[1].meta.is_selected = true
        test_helper.$rs.info_list_items[2].meta.is_selected = true
        test_helper.$rs.select_all = true
        test_helper.$rs.toggle_selected test_helper.$rs.info_list_items[1],
          ctrlKey: true

        expect(test_helper.$rs.select_all).toBeFalsy()


    describe "scope.watch select_all", ->
      it "sets selected properties to selected on all objects when select_all is true", ->
        test_helper.$rs.select_all = true
        test_helper.$rs.$apply()
        expect(test_helper.$rs.info_list_items[0].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[0].meta.question_class).toBe "questions__question questions__question--selected"
        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[1].meta.question_class).toBe "questions__question questions__question--selected"
        expect(test_helper.$rs.info_list_items[2].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[2].meta.question_class).toBe "questions__question questions__question--selected"

      it "sets selected properties to deselected on all objects when select_all is false", ->
        test_helper.$rs.select_all = false
        test_helper.$rs.$apply()
        expect(test_helper.$rs.info_list_items[0].meta.is_selected).toBeFalsy()
        expect(test_helper.$rs.info_list_items[0].meta.question_class).toBe "questions__question"
        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeFalsy()
        expect(test_helper.$rs.info_list_items[1].meta.question_class).toBe "questions__question"
        expect(test_helper.$rs.info_list_items[2].meta.is_selected).toBeFalsy()
        expect(test_helper.$rs.info_list_items[2].meta.question_class).toBe "questions__question"

      it "no-ops when select_all is null", ->
        test_helper.$rs.select_all = true
        test_helper.$rs.$apply()
        test_helper.$rs.select_all = null
        test_helper.$rs.$apply()

        expect(test_helper.$rs.info_list_items[0].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[0].meta.question_class).toBe "questions__question questions__question--selected"
        expect(test_helper.$rs.info_list_items[1].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[1].meta.question_class).toBe "questions__question questions__question--selected"
        expect(test_helper.$rs.info_list_items[2].meta.is_selected).toBeTruthy()
        expect(test_helper.$rs.info_list_items[2].meta.question_class).toBe "questions__question questions__question--selected"


    describe "$scope.delete_selected", ->
      it "deletes all selected items", ->
        test_helper.$rs.info_list_items[1].meta.is_selected = true
        test_helper.miscUtils.confirm.returns true

        test_helper.$scope.delete_selected()
        expect(test_helper.question_api_stub.remove).toHaveBeenCalledWith id: 2
        expect(test_helper.$rs.info_list_items.length).toBe 2
        expect(test_helper.$rs.info_list_items[0].id).toBe 1
        expect(test_helper.$rs.info_list_items[1].id).toBe 3

      it "no ops when confirmation returns false", ->
        test_helper.$rs.info_list_items[1].meta.is_selected = true
        test_helper.miscUtils.confirm.returns false

        test_helper.$scope.delete_selected()
        expect(test_helper.$rs.info_list_items.length).toBe 3
        expect(test_helper.$rs.info_list_items[0].id).toBe 1
        expect(test_helper.$rs.info_list_items[1].id).toBe 2
        expect(test_helper.$rs.info_list_items[2].id).toBe 3


  describe "Asset Editor Controller", ->
    beforeEach inject(($controller, $rootScope) ->
      test_helper.initializeController $controller, "AssetEditor", $rootScope
    )

    it "initializes the scope correctly", ->
      expect(test_helper.$rs.activeTab).toBe "Question Library > Edit question"


  describe "Header Controller", ->
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

  describe "Builder Controller", ->
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

        survey_factory_stub = sinon.stub(XLF.Survey, "create")
        survey_factory_stub.returns survey_stub
        survey_stub.toCSV.returns "test survey"


        test_helper.$rs.add_row_to_question_library "test row"

        expect(test_helper.survey_draft_api_stub.save).toHaveBeenCalledWith
          body: "test survey"
          asset_type: "question"

        expect(survey_stub.rows.add).toHaveBeenCalledWith "test row"



  describe "Import Controller", ->
    it "should initialize $scope and $rootScope correctly", inject(($controller, $rootScope) ->
      test_helper.initializeController $controller, "Import", $rootScope
      expect(test_helper.$scope.csrfToken).toBe "test token"
      expect(test_helper.$rs.canAddNew).toBe false
      expect(test_helper.$rs.activeTab).toBe "Import CSV"
    )
