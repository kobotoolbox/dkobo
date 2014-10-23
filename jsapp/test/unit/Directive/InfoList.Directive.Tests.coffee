info_list_directive_tests = ->
  _build_directive = (canAddNew, linkTo) ->
    test_helper.buildInfoListDirective canAddNew, linkTo
  beforeEach test_helper.mockUserDetails(null)
  beforeEach inject(($templateCache) ->
    $templateCache.put('templates/InfoList.Template.html', $templateCache.get('templates/InfoList.Template.html').replace('kobocat-form-publisher', ''))
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
      _build_directive false, "test"
      expect(test_helper.isolateScope.getHashLink(id: 1)).toBe "/test/1"

    it "should return a URI when linkTo is provided", () ->
      _build_directive false, ""
      expect(test_helper.isolateScope.getHashLink(id: 1)).toBe ""
