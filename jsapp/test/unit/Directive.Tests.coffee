directive_tests = ->
  mockUserDetails = (mockObject) ->
    module ($provide) ->
      $provide.provider "$userDetails", ->
        @$get = ->
          mockObject

        return

      $provide.provider "$miscUtils", ->
        @$get = ->
          bootstrapFileUploader: sinon.stub()

        return

      return

  buildDirective = ($compile, $rootScope, element) ->
    element = $compile(element)($rootScope)
    $rootScope.$apply()
    element.isolateScope()

  beforeEach test_helper.initialize_angular_modules

  describe "Top level menu Directive", ->
    buildTopLevelMenuDirective = ($compile, $rootScope) ->
      buildDirective $compile, $rootScope, "<div top-level-menu></div>"
    describe "Mocked $userDetails", ->
      beforeEach mockUserDetails(
        name: "test name"
        gravatar: "test avatar"
      )
      it "should set $rootScope.user to values passed by $userDetails", inject(($compile, $rootScope) ->
        isolateScope = buildTopLevelMenuDirective($compile, $rootScope)
        expect(isolateScope.user.name).toBe "test name"
        expect(isolateScope.user.avatar).toBe "test avatar"
        return
      )
      return

    describe "empty $userDetails", ->
      beforeEach mockUserDetails({})
      it "should set $rootScope.user to the default values when $userDetails is an empty object", inject(($compile, $rootScope) ->
        isolateScope = buildTopLevelMenuDirective($compile, $rootScope)
        expect(isolateScope.user.name).toBe "KoBoForm User"
        expect(isolateScope.user.avatar).toBe "/img/avatars/example-photo.jpg"
        return
      )
      return

    describe "null $userDetails", ->
      mockConfig = [
        title: "test title"
        icon: "fa-file-text-o"
        name: "test name"
      ]
      beforeEach mockUserDetails(null)
      beforeEach module(($provide) ->
        $provide.provider "$configuration", ->
          @$get = ->
            sections: ->
              mockConfig

          return

        return
      )
      it "should set $rootScope.user to the default values when $userDetails is null", inject(($compile, $rootScope) ->
        isolateScope = buildTopLevelMenuDirective($compile, $rootScope)
        expect(isolateScope.user.name).toBe "KoBoForm User"
        expect(isolateScope.user.avatar).toBe "/img/avatars/example-photo.jpg"
        return
      )
      it "should read section information from the config service", inject(($compile, $rootScope) ->
        isolateScope = buildTopLevelMenuDirective($compile, $rootScope)
        expect(isolateScope.sections).toBe mockConfig
        return
      )
      describe "scope.isActive", ->
        it "should return \"is-active\" when passed name equals the active tab", inject(($compile, $rootScope) ->
          isolateScope = buildTopLevelMenuDirective($compile, $rootScope)
          isolateScope.activeTab = "test tab"
          expect(isolateScope.isActive("test tab")).toBe "is-active"
          return
        )
        it "should return an empty string when passed name is different from the active tab", inject(($compile, $rootScope) ->
          isolateScope = buildTopLevelMenuDirective($compile, $rootScope)
          isolateScope.activeTab = "test tab 2"
          expect(isolateScope.isActive("test tab")).toBe ""
          return
        )
        return

      return

    return

  describe "InfoList Directive", ->
    buildInfoListDirective = ($compile, $rootScope, canAddNew, linkTo) ->
      buildDirective $compile, $rootScope, "<div info-list items=\"items\" can-add-new=\"" + canAddNew + "\" name=\"test\" link-to=\"" + linkTo + "\"></div>"
    it "should initialize the scope correctly", inject(($compile, $rootScope) ->
      $rootScope.items = [{}]
      buildInfoListDirective $compile, $rootScope, true
      expect($rootScope.canAddNew).toBe true
      expect($rootScope.activeTab).toBe "test"
      return
    )
    it "should initialize the scope with canAddNew === false when \"false\" is passed on directives attribute", inject(($compile, $rootScope) ->
      $rootScope.items = [{}]
      buildInfoListDirective $compile, $rootScope, false
      expect($rootScope.canAddNew).toBe false
      expect($rootScope.activeTab).toBe "test"
      return
    )
    describe "getHashLink", ->
      it "should return a URI when linkTo is provided", inject(($compile, $rootScope) ->
        isolateScope = buildInfoListDirective($compile, $rootScope, false, "test")
        expect(isolateScope.getHashLink(id: 1)).toBe "/test/1"
        return
      )
      it "should return a URI when linkTo is provided", inject(($compile, $rootScope) ->
        isolateScope = buildInfoListDirective($compile, $rootScope, false, "")
        expect(isolateScope.getHashLink(id: 1)).toBe ""
        return
      )
      return

    return

  return