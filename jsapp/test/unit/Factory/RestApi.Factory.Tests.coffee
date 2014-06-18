rest_api_factory_tests = ->
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
        publish:
          method: "POST"
          url: "/api/survey_drafts/:id/publish"
