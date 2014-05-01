service_tests = ->
  describe "RouteTo Service", ->
    describe "forms method", ->
      it "should redirect to \"/forms\" page", ->
        location = path: sinon.spy()
        router = new RouteToService(location)
        router.forms()
        expect(location.path).toHaveBeenCalledOn location
        expect(location.path).toHaveBeenCalledWith "/forms"
        return

      return

    return

  return