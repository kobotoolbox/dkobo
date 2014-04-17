describe "Controllers", ->
  hello = hello: "world"

  $rs = null
  $scope = null
  $resource = ->
    resourceStub

  miscServiceStub = ->
    @changeFileUploaderSuccess = sinon.spy()
    @confirm = _confirmStub
    return

  resourceStub = null
  _confirmStub = null
  initializeController = ($controller, name, $rootScope) ->
    $rs = $rootScope
    $scope = $rootScope
    $controller name + "Controller",
      $rootScope: $rs
      $scope: $scope
      $resource: $resource
      $routeParams: hello
      $cookies:
        csrftoken: "test token"

      $miscUtils: new miscServiceStub()
      $routeTo: sinon.stubObject(RouteToService)
      $restApi:
        create_question_api: ->
          resourceStub

        createSurveyDraftApi: ->
          resourceStub

  beforeEach ->
    sinon.stub(SurveyApp, "create").returns render: ->


  afterEach ->
    SurveyApp.create.restore()

  beforeEach ->
    window.$ = sinon.stub()
    $.withArgs(window).returns
      bind: sinon.stub()
      unbind: sinon.stub()

    $.withArgs("section.form-builder").returns get: sinon.stub()

  describe "Forms Controller", ->
    _confirmStub = null
    _deleteSpy = null
    beforeEach inject(($controller, $rootScope) ->
      resourceStub = query: (fn) ->
        fn hello

      _confirmStub = sinon.stub()
      _deleteSpy = sinon.spy()
      miscServiceStub = ->
        @confirm = _confirmStub
        @changeFileUploaderSuccess = sinon.spy()
        return

      initializeController $controller, "Forms", $rootScope
    )
    it "should initialize $rootScope and $scope correctly", ->
      expect($rs.canAddNew).toBe true
      expect($rs.activeTab).toBe "Forms"
      expect($scope.infoListItems).toBe hello

    describe "$scope.deleteSurvey", ->
      it "should delete survey when user confirms deletion", ->
        _confirmStub.returns true
        $scope.deleteSurvey
          id: 0
          $delete: _deleteSpy

        expect(_confirmStub).toHaveBeenCalledOnce()
        expect(_deleteSpy).toHaveBeenCalledOnce()

      it "should not delete survey when user cancels deletion", ->
        _confirmStub.returns false
        $scope.deleteSurvey
          id: 0
          $delete: _deleteSpy

        expect(_confirmStub).toHaveBeenCalledOnce()
        expect(_deleteSpy).not.toHaveBeenCalled()


    describe "$scope.$watch(\"infoListItems\")", ->
      it "should set additionalClasses = content-centered when infoListItems is empty", ->
        $rs.infoListItems = []
        $rs.$apply()
        expect($rs.additionalClasses).toBe "content--centered"

      it "should set additionalClasses = \"\" when infoListItems contains elements", ->
        $rs.infoListItems = [1]
        $rs.$apply()
        expect($rs.additionalClasses).toBe ""



  describe "Assets Controller", ->
    _items = undefined
    beforeEach inject(($controller, $rootScope) ->
      _items = [
        {
          id: 1
          label: "Currently, what is your main priority or concern?"
          type: "Select Many"
          meta: {}
        }
        {
          id: 2
          label: "If you have a dispute in your community, to whom do you take it first?"
          type: "Select Many"
          meta: {}
        }
        {
          id: 3
          label: "Why do you take it first to that person or institution?"
          type: "Select Many"
          meta: {}
        }
      ]
      _confirmStub = sinon.stub()
      miscServiceStub = ->

        @changeFileUploaderSuccess = sinon.spy()
        @confirm = _confirmStub
        return

      resourceStub =
        list: ->
          $rs.info_list_items = _items

        remove: sinon.spy()

      initializeController $controller, "Assets", $rootScope
    )
    it "should initialize $scope and $rootScope correctly", () ->
      expect($rs.canAddNew).toBe true
      expect($rs.activeTab).toBe "Question Library"
      expect($scope.info_list_items).toBe _items

    describe "$scope.toggle_response_list", ->
      it "shows responses when they are hidden", ->
        item =
          type: "select_one"
          meta:
            show_responses: false

        $rs.toggle_response_list item
        expect(item.meta.question_type_class).toBe "question__type question__type--expanded"
        expect(item.meta.question_type_icon_class).toBe "question__type-icon question__type--expanded-icon"
        expect(item.meta.question_type_icon).toBe "fa fa-caret-down"
        expect(item.meta.show_responses).toBe true

      it "hides responses when they are visible", ->
        item =
          type: "select_one"
          meta:
            show_responses: true

        $rs.toggle_response_list item
        expect(item.meta.show_responses).toBe false
        expect(item.meta.question_type_class).toBe "question__type"
        expect(item.meta.question_type_icon).toBe "fa fa-caret-right"
        expect(item.meta.question_type_icon_class).toBe "question__type-icon"


    describe "scope.toggle_selected", ->
      it "selects a deselected question", ->
        $rs.toggle_selected _items[1],
          ctrlKey: false

        expect(_items[1].meta.is_selected).toBeTruthy()
        expect(_items[1].meta.question_class).toBe "questions__question questions__question--selected"

      it "deselects a selected question", ->
        _items[1].meta.is_selected = true
        $rs.toggle_selected _items[1],
          ctrlKey: false

        expect(_items[1].meta.is_selected).toBeFalsy()
        expect(_items[1].meta.question_class).toBe "questions__question"

      it "deselects all previously selected questions", ->
        _items[0].meta.is_selected = true
        _items[2].meta.is_selected = true
        $rs.toggle_selected _items[1],
          ctrlKey: false

        expect(_items[0].meta.question_class).toBe "questions__question"
        expect(_items[0].meta.is_selected).toBeFalsy()
        expect(_items[1].meta.is_selected).toBeTruthy()
        expect(_items[2].meta.question_class).toBe "questions__question"
        expect(_items[2].meta.is_selected).toBeFalsy()

      it "keeps previously selected questions when ctrl is pressed", ->
        _items[0].meta.is_selected = true
        _items[2].meta.is_selected = true
        $rs.toggle_selected _items[1],
          ctrlKey: true

        expect(_items[0].meta.is_selected).toBeTruthy()
        expect(_items[1].meta.is_selected).toBeTruthy()
        expect(_items[2].meta.is_selected).toBeTruthy()

      it "deselects all questions except clicked question when multiple questions selected, current question selected and ctrl isnt pressed", ->
        _items[0].meta.is_selected = true
        _items[1].meta.is_selected = true
        _items[2].meta.is_selected = true
        $rs.toggle_selected _items[1],
          ctrlKey: false

        expect(_items[0].meta.is_selected).toBeFalsy()
        expect(_items[1].meta.is_selected).toBeTruthy()
        expect(_items[2].meta.is_selected).toBeFalsy()

      it "deselects a selected question when multiple questions selected and ctrl is pressed", ->
        _items[0].meta.is_selected = true
        _items[1].meta.is_selected = true
        _items[2].meta.is_selected = true
        $rs.toggle_selected _items[1],
          ctrlKey: true

        expect(_items[0].meta.is_selected).toBeTruthy()
        expect(_items[1].meta.is_selected).toBeFalsy()
        expect(_items[2].meta.is_selected).toBeTruthy()

      it "sets select_all switch when all questions selected", ->
        _items[0].meta.is_selected = true
        _items[2].meta.is_selected = true
        $rs.toggle_selected _items[1],
          ctrlKey: true

        expect($rs.select_all).toBeTruthy()

      it "clears select_all switch when not all questions selected", ->
        _items[0].meta.is_selected = true
        _items[1].meta.is_selected = true
        _items[2].meta.is_selected = true
        $rs.select_all = true
        $rs.toggle_selected _items[1],
          ctrlKey: true

        expect($rs.select_all).toBeFalsy()


    describe "scope.watch select_all", ->
      it "sets selected properties to selected on all objects when select_all is true", ->
        $rs.select_all = true
        $rs.$apply()
        expect(_items[0].meta.is_selected).toBeTruthy()
        expect(_items[0].meta.question_class).toBe "questions__question questions__question--selected"
        expect(_items[1].meta.is_selected).toBeTruthy()
        expect(_items[1].meta.question_class).toBe "questions__question questions__question--selected"
        expect(_items[2].meta.is_selected).toBeTruthy()
        expect(_items[2].meta.question_class).toBe "questions__question questions__question--selected"

      it "sets selected properties to deselected on all objects when select_all is false", ->
        $rs.select_all = false
        $rs.$apply()
        expect(_items[0].meta.is_selected).toBeFalsy()
        expect(_items[0].meta.question_class).toBe "questions__question"
        expect(_items[1].meta.is_selected).toBeFalsy()
        expect(_items[1].meta.question_class).toBe "questions__question"
        expect(_items[2].meta.is_selected).toBeFalsy()
        expect(_items[2].meta.question_class).toBe "questions__question"

      it "no-ops when select_all is null", ->
        $rs.select_all = true
        $rs.$apply()
        $rs.select_all = null
        $rs.$apply()
        expect(_items[0].meta.is_selected).toBeTruthy()
        expect(_items[0].meta.question_class).toBe "questions__question questions__question--selected"
        expect(_items[1].meta.is_selected).toBeTruthy()
        expect(_items[1].meta.question_class).toBe "questions__question questions__question--selected"
        expect(_items[2].meta.is_selected).toBeTruthy()
        expect(_items[2].meta.question_class).toBe "questions__question questions__question--selected"


    describe "$scope.delete_selected", ->
      it "deletes all selected items", ->
        _items[1].meta.is_selected = true
        _confirmStub.returns true
        $scope.delete_selected()
        expect(resourceStub.remove).toHaveBeenCalledWith id: 2
        expect($rs.info_list_items.length).toBe 2
        expect($rs.info_list_items[0].id).toBe 1
        expect($rs.info_list_items[1].id).toBe 3

      it "no ops when confirmation returns false", ->
        _items[1].meta.is_selected = true
        _confirmStub.returns false
        $scope.delete_selected()
        expect($rs.info_list_items.length).toBe 3
        expect($rs.info_list_items[0].id).toBe 1
        expect($rs.info_list_items[1].id).toBe 2
        expect($rs.info_list_items[2].id).toBe 3


  describe "Asset Editor Controller", ->
    beforeEach inject(($controller, $rootScope) ->

      initializeController $controller, "AssetEditor", $rootScope
    )

    it "initializes the scope correctly", ->
      expect($rs.activeTab).toBe "Question Library > Edit question"


  describe "Header Controller", ->
    beforeEach inject(($controller, $rootScope) ->
      miscServiceStub = ->
        @bootstrapFileUploader = ->
        @changeFileUploaderSuccess = sinon.spy()
        return

      initializeController $controller, "Header", $rootScope
    )
    it "should initialize $scope and $rootScope correctly", ->
      expect($scope.pageIconColor).toBe "teal"
      expect($scope.pageTitle).toBe "Forms"
      expect($scope.pageIcon).toBe "fa-file-text-o"
      expect($scope.topLevelMenuActive).toBe ""
      expect($rs.activeTab).toBe "Forms"

    describe "$scope.toggleTopMenu", ->
      it "should set the value of $scope.topLevelMenuActive to \"is-active\" when its value is an empty string", ->
        $rs.topLevelMenuActive = ""
        $scope.toggleTopMenu()
        expect($rs.topLevelMenuActive).toBe "is-active"

      it "should set the value of $scope.topLevelMenuActive to an empty string when its value is \"is-active\"", ->
        $rs.topLevelMenuActive = "is-active"
        $scope.toggleTopMenu()
        expect($rs.topLevelMenuActive).toBe ""



  describe "Builder Controller", ->
    _confirmStub = null
    _preventDefaultSpy = null
    beforeEach inject(($controller, $rootScope) ->
      _confirmStub = sinon.stub()
      _preventDefaultSpy = sinon.spy()
      miscServiceStub = ->
        @confirm = _confirmStub
        @preventDefault = _preventDefaultSpy
        @changeFileUploaderSuccess = sinon.spy()
        return

      initializeController $controller, "Builder", $rootScope
    )
    afterEach ->
      miscServiceStub = ->


    it "should initialize $scope and $rootScope correctly", ->
      expect($rs.activeTab).toBe "Forms"
      expect($scope.routeParams).toBe hello

    describe "Location Change Confirmation", ->
      it "Should change location when user accepts confirmation", ->
        _confirmStub.returns true
        $rs.deregisterLocationChangeStart = sinon.spy()
        $rs.$broadcast "$locationChangeStart"
        expect(_confirmStub).toHaveBeenCalledOnce()
        expect(_confirmStub).toHaveBeenCalledWith "Are you sure you want to leave? you will lose any unsaved changes."
        expect($rs.deregisterLocationChangeStart).toHaveBeenCalledOnce()

      it "Should keep location when user rejects confirmation", ->
        _confirmStub.returns false
        $rs.$broadcast "$locationChangeStart"
        expect(_confirmStub).toHaveBeenCalledOnce()
        expect(_confirmStub).toHaveBeenCalledWith "Are you sure you want to leave? you will lose any unsaved changes."
        expect(_preventDefaultSpy).toHaveBeenCalledOnce()


    describe "$scope.add_row_to_question_library", ->
      it "posts a survey object to the server", ->
        survey_stub =
          rows:
            add: sinon.spy()
          toCSV: sinon.stub()

        survey_factory_stub = sinon.stub(XLF.Survey, "create")
        survey_factory_stub.returns survey_stub
        survey_stub.toCSV.returns "test survey"
        resourceStub = save: sinon.spy()
        $rs.add_row_to_question_library "test row"
        expect(resourceStub.save).toHaveBeenCalledWith
          body: "test survey"
          asset_type: "question"

        expect(survey_stub.rows.add).toHaveBeenCalledWith "test row"



  describe "Import Controller", ->
    it "should initialize $scope and $rootScope correctly", inject(($controller, $rootScope) ->
      initializeController $controller, "Import", $rootScope
      expect($scope.csrfToken).toBe "test token"
      expect($rs.canAddNew).toBe false
      expect($rs.activeTab).toBe "Import CSV"
    )
