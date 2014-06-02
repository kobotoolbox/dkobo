assets_controller_tests = ->
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
