top_level_menu_directive_tests = ->
  describe "Mocked $userDetails", ->
    beforeEach test_helper.mockUserDetails(
      name: "test name"
      gravatar: "test avatar"
    )
    beforeEach () ->
      test_helper.buildTopLevelMenuDirective()

    it "should set $rootScope.user to values passed by $userDetails", () ->
      expect(test_helper.isolateScope.user.name).toBe "test name"
      expect(test_helper.isolateScope.user.avatar).toBe "test avatar"

  describe "empty $userDetails", ->
    beforeEach test_helper.mockUserDetails({})
    beforeEach inject (($compile, $rootScope) ->
      test_helper.buildTopLevelMenuDirective($compile, $rootScope)
    )
    it "should set $rootScope.user to the default values when $userDetails is an empty object", () ->
      expect(test_helper.isolateScope.user.name).toBe "KoBoForm User"
      expect(test_helper.isolateScope.user.avatar).toBe "/img/avatars/example-photo.jpg"

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
      test_helper.buildTopLevelMenuDirective($compile, $rootScope)
    )
    it "should set $rootScope.user to the default values when $userDetails is null", () ->
      expect(test_helper.isolateScope.user.name).toBe "KoBoForm User"
      expect(test_helper.isolateScope.user.avatar).toBe "/img/avatars/example-photo.jpg"

    it "should read section information from the config service", () ->
      expect(test_helper.isolateScope.sections).toBe mockConfig

    describe "scope.isActive", ->
      it "should return \"is-active\" when passed name equals the active tab", () ->
        test_helper.isolateScope.activeTab = "test tab"
        expect(test_helper.isolateScope.isActive("test tab")).toBe "is-active"

      it "should return an empty string when passed name is different from the active tab", () ->
        test_helper.isolateScope.activeTab = "test tab 2"
        expect(test_helper.isolateScope.isActive("test tab")).toBe ""
