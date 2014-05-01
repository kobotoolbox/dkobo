factory_tests = ->
  describe "userDetails Factory", ->
    it "should return the value of window.userDetails", ->
      window.userDetails = {}
      expect(userDetailsFactory()).toBe window.userDetails

  describe "restApi Factory", ->
    describe "createSurveyDraftApi", ->
      it "should invoke $resource with an empty object when no id is provided", ->
        resourceSpy = sinon.spy()
        factory = restApiFactory(resourceSpy)
        factory.createSurveyDraftApi()
        expect(resourceSpy).toHaveBeenCalledWith "/api/survey_drafts"

      it "should invoke $resource with a custom save object when an id is provided", ->
        resourceSpy = sinon.spy()
        factory = restApiFactory(resourceSpy)
        factory.createSurveyDraftApi 1
        expect(resourceSpy).toHaveBeenCalledWith "/api/survey_drafts/:id",
          id: 1
        ,
          save:
            method: "PATCH"