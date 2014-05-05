directive_tests = ->
  beforeEach test_helper.initialize_angular_modules

  describe "Top level menu Directive", ->
    _isolateScope = null
    describe "Mocked $userDetails", ->
      beforeEach test_helper.mockUserDetails(
        name: "test name"
        gravatar: "test avatar"
      )
      beforeEach inject (($compile, $rootScope) ->
        _isolateScope = test_helper.buildTopLevelMenuDirective($compile, $rootScope)
      )
      it "should set $rootScope.user to values passed by $userDetails", () ->
        expect(_isolateScope.user.name).toBe "test name"
        expect(_isolateScope.user.avatar).toBe "test avatar"

    describe "empty $userDetails", ->
      beforeEach test_helper.mockUserDetails({})
      beforeEach inject (($compile, $rootScope) ->
        _isolateScope = test_helper.buildTopLevelMenuDirective($compile, $rootScope)
      )
      it "should set $rootScope.user to the default values when $userDetails is an empty object", () ->
        expect(_isolateScope.user.name).toBe "KoBoForm User"
        expect(_isolateScope.user.avatar).toBe "/img/avatars/example-photo.jpg"

    describe "null $userDetails", ->
      mockConfig = [
        title: "test title"
        icon: "fa-file-text-o"
        name: "test name"
      ]
      beforeEach test_helper.mockUserDetails(null)
      beforeEach module(($provide) ->
        $provide.provider "$configuration", ->
          @$get = ->
            sections: ->
              mockConfig
          return
        return
      )
      beforeEach inject (($compile, $rootScope) ->
        _isolateScope = test_helper.buildTopLevelMenuDirective($compile, $rootScope)
      )
      it "should set $rootScope.user to the default values when $userDetails is null", () ->
        expect(_isolateScope.user.name).toBe "KoBoForm User"
        expect(_isolateScope.user.avatar).toBe "/img/avatars/example-photo.jpg"

      it "should read section information from the config service", () ->
        expect(_isolateScope.sections).toBe mockConfig

      describe "scope.isActive", ->
        it "should return \"is-active\" when passed name equals the active tab", () ->
          _isolateScope.activeTab = "test tab"
          expect(_isolateScope.isActive("test tab")).toBe "is-active"

        it "should return an empty string when passed name is different from the active tab", () ->
          _isolateScope.activeTab = "test tab 2"
          expect(_isolateScope.isActive("test tab")).toBe ""

  describe "InfoList Directive", ->
    _build_directive = null
    beforeEach inject(($compile, $rootScope) ->
      $rootScope.items = [{}]
      _build_directive = (canAddNew, linkTo) ->
        test_helper.buildInfoListDirective $compile, $rootScope, canAddNew, linkTo
    )

    it "should initialize the scope correctly", () ->
      _build_directive true
      expect(test_helper.$rs.canAddNew).toBe true
      expect(test_helper.$rs.activeTab).toBe "test"

    it "should initialize the scope with canAddNew === false when \"false\" is passed on directives attribute", () ->
      _build_directive false
      expect(test_helper.$rs.canAddNew).toBe false

    describe "getHashLink", ->
      it "should return a URI when linkTo is provided", () ->
        isolateScope = _build_directive false, "test"
        expect(isolateScope.getHashLink(id: 1)).toBe "/test/1"

      it "should return a URI when linkTo is provided", () ->
        isolateScope = _build_directive false, ""
        expect(isolateScope.getHashLink(id: 1)).toBe ""