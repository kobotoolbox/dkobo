test_helper =
  $api:
    surveys:
      list: sinon.stub()
      get: sinon.stub()
      save: sinon.stub()
      remove: sinon.stub()
      reload: sinon.stub()
    questions:
      list: () -> return @items = _.clone test_helper.items, true
      get: sinon.stub()
      save: sinon.stub().returns then: ()->
      remove: sinon.stub()
      reload: sinon.stub()
    tags:
      list: sinon.stub()
      get: sinon.stub()
      save: sinon.stub()
      remove: sinon.stub()
      reload: sinon.stub()
  initialize_angular_modules: () ->
    module "dkobo"
    module "templates/TopLevelMenu.Template.html"
    module "templates/InfoList.Template.html"
    module "templates/ItemList.Directive.Template.html"
    module "templates/KobocatFormPublisher.Template.html"
  initializeController: (@$controller, name, $rootScope, $userDetails = {}) ->
    @$rs = $rootScope
    @$scope = $rootScope
    @$resource = sinon.stub()
    @$resource.returns _.clone @resource_stub
    @hello = hello: 'world'
    @miscUtils = new @miscServiceStub()

    that = @

    @$controller name + "Controller",
      $userDetails: $userDetails
      $rootScope: @$rs
      $scope: @$scope
      $resource: @$resource
      $routeParams: @hello
      $cookies:
        csrftoken: "test token"

      $filter: () -> () ->
      $miscUtils: @miscUtils
      $routeTo: sinon.stubObject
        forms: () ->
        builder: () ->
        question_library: () ->
        external: () ->
      $restApi:
        create_question_api: =>
          @question_api_stub = _.clone @resource_stub
          @question_api_stub.list = () => @$rs.info_list_items = _.clone @items, true
          @question_api_stub
        createSurveyDraftApi: =>
          @survey_draft_api_stub = _.clone @resource_stub
          @survey_draft_api_stub.list = () => @$rs.info_list_items = _.clone @items, true
          @survey_draft_api_stub
      $api: @$api

  miscServiceStub: ->
    @confirm = sinon.stub()
    @preventDefault = sinon.spy()
    @changeFileUploaderSuccess = sinon.spy()
    @bootstrapFileUploader = sinon.spy()
    @bootstrapSurveyUploader = sinon.spy()
    @bootstrapQuestionUploader = sinon.spy()
    return
  buildDirective: (element) ->
    inject ($compile, $rootScope) =>
      @$rs = $rootScope
      $rootScope.items = [{}]
      @$rs.filters = {}
      @$rs.sort_criteria = {}
      compiled = $compile(element)
      element = compiled($rootScope)
      $rootScope.$apply()
      test_helper.isolateScope = element.isolateScope()

  buildInfoListDirective: (canAddNew, linkTo) ->
    test_helper.buildDirective "<div info-list items=\"items\" can-add-new=\"" + canAddNew + "\" name=\"test\" link-to=\"" + linkTo + "\"></div>"
  buildItemListDirective: () ->
    test_helper.buildDirective "<div item-list rest-api=\"questions\" filters=\"filters\" sort-criteria=\"sort_criteria\" base-class=\"questions__question\" full-edit=\"true\" full-edit-class=\"question__edit\"></div>"


  buildTopLevelMenuDirective: () ->
    test_helper.buildDirective "<div top-level-menu></div>"
  mockUserDetails: (mockObject) ->
    module ($provide) ->
      $provide.provider "$userDetails", ->
        @$get = ->
          mockObject

        return

      $provide.provider "$miscUtils", ->
        @$get = ->
          bootstrapFileUploader: sinon.stub()
          changeFileUploaderSuccess: sinon.stub()
          bootstrapSurveyUploader: sinon.spy()

        return

      return

  mockApiService: () ->
    module ($provide) ->
      $provide.provider "$api", ->
        @$get = ->
          test_helper.$api

        return
      return

  resource_stub:
    get: sinon.stub()
    list: sinon.stub()
    query: sinon.stub()
    save: sinon.stub()
    remove: sinon.stub()
  items: [
    {
      id: 1
      label: "Currently, what is your main priority or concern?"
      type: "Select Many"
      meta: {}
    }
    {
      id: 2
      label: "If you have a dispute in your community, to whom do you take it first?"
      type: "Select Many"
      meta: {}
    }
    {
      id: 3
      label: "Why do you take it first to that person or institution?"
      type: "Select Many"
      meta: {}
    }
  ]


describe '', () ->
  beforeEach ->
    sinon.stub(window, '$')

    $.withArgs(window).returns
      bind: sinon.stub()
      unbind: sinon.stub()

    $.withArgs("section.form-builder").returns get: sinon.stub()

  afterEach () ->
    window.$.restore()

  describe 'Controllers', controller_tests
  describe 'Directives', directive_tests
  describe 'Factories', factory_tests
  describe 'Services', service_tests
  describe 'Skip Logic Parser', skip_logic_parser_tests
  describe 'Validation Logic Parser', validation_logic_parser_tests
  describe 'Validator', validator_tests

