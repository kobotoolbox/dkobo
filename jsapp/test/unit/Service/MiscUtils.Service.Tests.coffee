misc_utils_service_tests = ->
  describe "toggle_response_list", ->
    it "shows responses when they are hidden", ->
      item =
        type: "select_one"
        meta:
          show_responses: false

      $injector = angular.injector([ 'dkobo' ]);
      service = $injector.get( '$miscUtils' );

      service.toggle_response_list item
      expect(item.meta.question_type_class).toBe "question__type question__type--expanded"
      expect(item.meta.question_type_icon_class).toBe "question__type-icon question__type--expanded-icon"
      expect(item.meta.question_type_icon).toBe "fa fa-caret-down"
      expect(item.meta.show_responses).toBe true

    it "hides responses when they are visible", ->
      item =
        type: "select_one"
        meta:
          show_responses: true

      $injector = angular.injector([ 'dkobo' ]);
      service = $injector.get( '$miscUtils' );

      service.toggle_response_list item

      expect(item.meta.show_responses).toBe false
      expect(item.meta.question_type_class).toBe "question__type"
      expect(item.meta.question_type_icon).toBe "fa fa-caret-right"
      expect(item.meta.question_type_icon_class).toBe "question__type-icon"