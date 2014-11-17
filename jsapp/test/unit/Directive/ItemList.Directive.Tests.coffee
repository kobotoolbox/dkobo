item_list_directive_tests = ->
###  _build_directive = () ->
    test_helper.buildItemListDirective()

  beforeEach test_helper.mockApiService()
  beforeEach inject(($templateCache) ->
    $templateCache.put('templates/ItemList.Directive.Template.html', $templateCache.get('templates/ItemList.Directive.Template.html').replace('inner-transclude', ''))
  )
  describe "scope.toggle_selected", ->
    it "selects a deselected question", ->
      _build_directive()
      test_helper.isolateScope.toggle_selected test_helper.$rs.items[1],
        ctrlKey: false

      expect(test_helper.$rs.items[1].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.items[1].meta.additionalClasses).toBe "questions__question--selected"

    it "deselects a selected question", ->
      test_helper.$rs.items[1].meta.is_selected = true
      test_helper.$rs.toggle_selected test_helper.$rs.items[1],
        ctrlKey: false

      expect(test_helper.$rs.items[1].meta.is_selected).toBeFalsy()
      expect(test_helper.$rs.items[1].meta.additionalClasses).toBe "questions__question"

    it "deselects all previously selected questions", ->
      test_helper.$rs.items[0].meta.is_selected = true
      test_helper.$rs.items[2].meta.is_selected = true
      test_helper.$rs.toggle_selected test_helper.$rs.items[1],
        ctrlKey: false

      expect(test_helper.$rs.items[0].meta.additionalClasses).toBe "questions__question"
      expect(test_helper.$rs.items[0].meta.is_selected).toBeFalsy()
      expect(test_helper.$rs.items[1].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.items[2].meta.additionalClasses).toBe "questions__question"
      expect(test_helper.$rs.items[2].meta.is_selected).toBeFalsy()

    it "keeps previously selected questions when ctrl is pressed", ->
      test_helper.$rs.items[0].meta.is_selected = true
      test_helper.$rs.items[2].meta.is_selected = true
      test_helper.$rs.toggle_selected test_helper.$rs.items[1],
        ctrlKey: true

      expect(test_helper.$rs.items[0].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.items[1].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.items[2].meta.is_selected).toBeTruthy()

    it "deselects all questions except clicked question when multiple questions selected, current question selected and ctrl isnt pressed", ->
      test_helper.$rs.items[0].meta.is_selected = true
      test_helper.$rs.items[1].meta.is_selected = true
      test_helper.$rs.items[2].meta.is_selected = true
      test_helper.$rs.toggle_selected test_helper.$rs.items[1],
        ctrlKey: false

      expect(test_helper.$rs.items[0].meta.is_selected).toBeFalsy()
      expect(test_helper.$rs.items[1].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.items[2].meta.is_selected).toBeFalsy()

    it "deselects a selected question when multiple questions selected and ctrl is pressed", ->
      test_helper.$rs.items[0].meta.is_selected = true
      test_helper.$rs.items[1].meta.is_selected = true
      test_helper.$rs.items[2].meta.is_selected = true
      test_helper.$rs.toggle_selected test_helper.$rs.items[1],
        ctrlKey: true

      expect(test_helper.$rs.items[0].meta.is_selected).toBeTruthy()
      expect(test_helper.$rs.items[1].meta.is_selected).toBeFalsy()
      expect(test_helper.$rs.items[2].meta.is_selected).toBeTruthy()

    it "sets select_all switch when all questions selected", ->
      test_helper.$rs.items[0].meta.is_selected = true
      test_helper.$rs.items[2].meta.is_selected = true
      test_helper.$rs.toggle_selected test_helper.$rs.items[1],
        ctrlKey: true

      expect(test_helper.$rs.select_all).toBeTruthy()

    it "clears select_all switch when not all questions selected", ->
      _build_directive()
      test_helper.isolateScope.api.items[0].meta.is_selected = true
      test_helper.isolateScope.api.items[1].meta.is_selected = true
      test_helper.isolateScope.api.items[2].meta.is_selected = true
      test_helper.$rs.select_all = true
      test_helper.$rs.toggle_selected test_helper.isolateScope.api.items[1],
        ctrlKey: true

      expect(test_helper.$rs.select_all).toBeFalsy()

###
