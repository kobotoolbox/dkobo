test_helper =
  initialize_angular_modules: () ->
    module "dkobo"
    module "templates/TopLevelMenu.Template.html"
    module "templates/InfoList.Template.html"
  initializeController: (@$controller, name, $rootScope) ->
    @$rs = $rootScope
    @$scope = $rootScope
    @$resource = sinon.stub()
    @$resource.returns _.clone @resource_stub
    @hello = hello: 'world'
    @miscUtils = new @miscServiceStub()

    @$controller name + "Controller",
      $rootScope: @$rs
      $scope: @$scope
      $resource: @$resource
      $routeParams: @hello
      $cookies:
        csrftoken: "test token"

      $miscUtils: @miscUtils
      $routeTo: sinon.stubObject(RouteToService)
      $restApi:
        create_question_api: =>
          @question_api_stub = _.clone @resource_stub
          @question_api_stub.list = () => @$rs.info_list_items = _.clone @items, true
          @question_api_stub
        createSurveyDraftApi: =>
          @survey_draft_api_stub = _.clone @resource_stub
          @survey_draft_api_stub.list = () => @$rs.info_list_items = _.clone @items, true
          @survey_draft_api_stub

  miscServiceStub: ->
    @confirm = sinon.stub()
    @preventDefault = sinon.spy()
    @changeFileUploaderSuccess = sinon.spy()
    @bootstrapFileUploader = sinon.spy()
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
    window.$ = sinon.stub()
    $.withArgs(window).returns
      bind: sinon.stub()
      unbind: sinon.stub()

    $.withArgs("section.form-builder").returns get: sinon.stub()

  describe 'Controllers', controller_tests
  describe 'Directives', directive_tests
  describe 'Factories', factory_tests
  describe 'Services', service_tests
  describe 'Skip Logic Parser', skip_logic_parser_tests
  describe 'Validator', validator_tests