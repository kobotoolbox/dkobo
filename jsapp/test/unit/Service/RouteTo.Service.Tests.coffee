route_to_service_tests = ->
  describe "forms method", ->
    it "should redirect to \"/forms\" page", ->

      module('dkobo')
      location = path: sinon.spy()

      module ($provide) ->
        $provide.provider "$location", ->
          @$get = ->
            location

          return
        return

      inject ($routeTo) ->


        $routeTo.forms()
        expect(location.path).toHaveBeenCalledOn location
        expect(location.path).toHaveBeenCalledWith "/forms"