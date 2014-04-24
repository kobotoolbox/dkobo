describe 'skip logic model', () ->
  describe 'skip logic factory', () ->
    _factory = new XLF.Model.SkipLogicFactory()

    beforeEach ->
      @addMatchers toBeInstanceOf: (expectedInstance) ->
        actual = @actual
        notText = (if @isNot then " not" else "")
        @message = ->
          "Expected " + actual.constructor.name + notText + " is instance of " + expectedInstance.name

        actual instanceof expectedInstance

      return


    it 'creates a basic skip logic operator', () ->
      operator = _factory.create_operator 'basic', '=', 1

      expect(operator).toBeInstanceOf XLF.SkipLogicOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates a text skip logic operator', () ->
      operator = _factory.create_operator 'text', '=', 1

      expect(operator).toBeInstanceOf XLF.TextOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates an existence skip logic operator', () ->
      operator = _factory.create_operator 'existence', '=', 1

      expect(operator).toBeInstanceOf XLF.ExistenceSkipLogicOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates a select multiple skip logic operator', () ->
      operator = _factory.create_operator 'select_multiple', '=', 1

      expect(operator).toBeInstanceOf XLF.SelectMultipleSkipLogicOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates an empty skip logic operator', () ->
      operator = _factory.create_operator 'empty', '=', 1

      expect(operator).toBeInstanceOf XLF.EmptyOperator
      expect(operator.get('id')).toBe 0
      expect(operator.get('symbol')).toBeUndefined()

    it 'creates a criterion model', () ->
      criterion = _factory.create_criterion_model 'test question', 'test operator'

      expect(criterion).toBeInstanceOf XLF.SkipLogicCriterion

    it 'creates a text response model', () ->
      expect(_factory.create_response_model 'text').toBeInstanceOf XLF.Model.ResponseModel

    it 'creates an integer response model', () ->
      expect(_factory.create_response_model 'integer').toBeInstanceOf XLF.Model.IntegerResponseModel

    it 'creates a decimal response model', () ->
      expect(_factory.create_response_model 'decimal').toBeInstanceOf XLF.Model.DecimalResponseModel

  ###*******************************************************************************************************************
  ***----------------------------------------------------------------------------------------------------------------***
  *******************************************************************************************************************###

  describe 'skip logic criterion', () ->
    _criterion = null
    _operator = null
    _survey = null
    _factory = null
    _survey = null


    beforeEach () ->
      _survey =
        rows:
          get: sinon.stub().withArgs('test').returns(getType: () -> operators: [1, 2])
      _criterion = new XLF.SkipLogicCriterion

      _operator =
        serialize: sinon.stub().withArgs('test question', 'test value').returns 'test criterion'
      _factory = sinon.stub()

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'serialize method', () ->
      beforeEach () ->
        _criterion._get_question = sinon.stub().returns
          get: sinon.stub().returns(get: sinon.stub().returns 'test question')
          finalize: () ->

        _criterion.set 'question_cid', 'test question'
        _criterion.set 'operator', _operator

      it 'serializes the criterion when response model validation state is true', () ->
        response_model =
          isValid: () -> true
          get: () -> 'test value'

        _criterion.set 'response_value', response_model

        expect(_criterion.serialize()).toBe 'test criterion'
      it 'serializes the criterion when response model validation state is undefined', () ->
        response_model =
          isValid: () -> undefined
          get: () -> 'test value'

        _criterion.set 'response_value', response_model

        expect(_criterion.serialize()).toBe 'test criterion'
      it 'serializes to empty value when response model validation state is false', () ->
        response_model =
          isValid: () -> false

        _criterion.set 'response_value', response_model

        expect(_criterion.serialize()).toBe ''


    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'get question', () ->
      it 'returns current question', () ->
        _criterion.survey =
          rows:
            get: sinon.stub().withArgs('test').returns 'success'
        _criterion.set 'question_cid', 'test'

        expect(_criterion._get_question()).toBe 'success'

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'change question', () ->
      beforeEach () ->
        _criterion.survey = _survey
        _criterion._get_question = sinon.stub().returns(get_type: sinon.stub().returns(response_type: 'text', operators: [1, 2]))
        _criterion.change_operator = sinon.spy()
        _criterion.change_response = sinon.spy()

        _criterion.set 'operator',
          get_id: () -> return -1
          get_type: () -> {}
          get_value: () -> -1

        _criterion.set 'response_value',
          get: sinon.stub().withArgs('value').returns('test')
          get_type: sinon.stub().returns('test')

      it 'changes questions cid', () ->
        _criterion.change_question 'test question'

        expect(_criterion.get 'question_cid').toBe 'test question'

      it 'changes current operator if not in new question type', () ->
        _criterion.change_question('test')

        expect(_criterion.change_operator).toHaveBeenCalledWith 1

      it 'keeps current operator if in new question type', () ->
        _criterion._get_question = sinon.stub().withArgs('operator in question type').returns(get_type: () -> {operators: [-1], name: 'test'})
        _criterion.change_question('operator in question type')

        expect(_criterion.change_operator).not.toHaveBeenCalled()

      it 'changes response model if response type is different from new questions response type', () ->
        _criterion.change_question('test')

        expect(_criterion.change_response).toHaveBeenCalledWith 'test'

      it 'keeps response model if response type is specified by operator type', () ->
        _criterion.get('operator').get_type = () -> response_type: 'test'
        _criterion.change_question('test')

        expect(_criterion.change_response).not.toHaveBeenCalled()

      it 'changes operator when question type changes', () ->
        get_question_stub = sinon.stub()
        get_question_stub.onCall(0).returns get_type: () -> {response_type: 'text', operators: [1, 2]}
        get_question_stub.returns get_type: () -> {operators: [-1], name: 'test'}

        _criterion._get_question = get_question_stub
        _criterion.change_question('test')

        expect(_criterion.change_operator).toHaveBeenCalledWith -1

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'change operator', () ->
      beforeEach () ->
        _criterion.factory = create_operator: sinon.stub().withArgs('existence', '=', 1).returns 'test operator'
        _criterion._get_question = sinon.stub().returns(get_type: sinon.stub().returns(response_type: 'text', operators: [1, 2], equality_operator_type: 'text'))
        _criterion.change_response = sinon.spy()
        response_value_getter = sinon.stub()
        response_value_getter.withArgs('type').returns('none')
        response_value_getter.withArgs('value').returns('test')

        _criterion.set 'response_value', get: response_value_getter
      it 'changes the operator model', () ->
        _criterion.change_operator 1

        expect(_criterion.get 'operator').toBe 'test operator'

      it 'changes the operator model with negated criterion', () ->
        _criterion.change_operator -1

        expect(_criterion.get 'operator').toBe 'test operator'

      it 'validates that passed operator is in question type operators list', () ->
        _criterion.change_operator 24

        expect(_criterion.get 'operator').toBe undefined

      it "changes response model when operator's response type is different from current's", () ->
        _criterion.change_operator 1

        expect(_criterion.change_response).toHaveBeenCalledWith 'test'

      it "uses question's equality operator when operator type is equality", () ->
        _criterion.factory.create_operator = sinon.stub()
        _criterion.factory.create_operator.withArgs('text', '=', 2).returns 'test operator'
        _criterion.change_operator 2

        expect(_criterion.get 'operator').toBe 'test operator'


    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'set option names', () ->
      it 'sets option names to sluggified version of their labels', () ->
        options = [
          new Backbone.Model(label: 'Option 1')
          new Backbone.Model(label: 'Option 2')
        ]

        _criterion.set_option_names options

        expect(options[0].get('name')).toBe 'option_1'
        expect(options[1].get('name')).toBe 'option_2'

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'change response value', () ->
      __getter = null
      beforeEach () ->
        response_model = set_value: sinon.spy()
        response_value_getter = sinon.stub()
        response_value_getter.withArgs('type').returns('none')
        response_value_getter.withArgs('value').returns('test')
        response_model.get = response_value_getter
        _criterion.set 'operator', get_type: () -> {}
        _question_getter = sinon.stub()

        _criterion._get_question = sinon.stub().returns(get_type: sinon.stub().returns(response_type: 'text'), getList: () -> options: models: [{get: sinon.stub().returns('test option')}, {get: sinon.stub().returns('test option 2')}, {get: sinon.stub().returns('test option 3')}])

        _criterion.factory = create_response_model: sinon.stub().returns set_value: sinon.spy()
        _criterion.set 'response_value', response_model
      it 'changes response value', () ->
        _criterion.change_response 'test value'
        expect(_criterion.get('response_value').set_value).toHaveBeenCalledWith 'test value'
      it 'changes response model when question type specifies different response type', () ->
        _criterion._get_question = sinon.stub().returns(get_type: sinon.stub().returns(response_type: 'integer'))
        _criterion.change_response(12)

        expect(_criterion.factory.create_response_model).toHaveBeenCalledWith 'integer'
      it "gives operator's response type precedence", () ->
        _criterion.set 'operator', get_type: () -> response_type: 'empty'
        _criterion.change_response null

        expect(_criterion.factory.create_response_model).toHaveBeenCalledWith 'empty'

      it 'sets value to first option for select question types', () ->
        _criterion.get_correct_type = sinon.stub().returns('dropdown')

        _criterion.change_response 'test'

        expect(_criterion.get('response_value').set_value).toHaveBeenCalledWith 'test option'

      it 'keeps current value when it is valid option for select question types', () ->
        _criterion.get_correct_type = sinon.stub().returns('dropdown')
        _criterion.get('response_value').get.withArgs('value').returns('test option 2')

        _criterion.change_response 'test'

        expect(_criterion.get('response_value').set_value).toHaveBeenCalledWith 'test option 2'

      it 'uses passed value when in choice list', () ->
        _criterion.get_correct_type = sinon.stub().returns('dropdown')
        _criterion.get('response_value').get.withArgs('value').returns('test option 2')

        _criterion.change_response 'test option 3'

        expect(_criterion.get('response_value').set_value).toHaveBeenCalledWith 'test option 3'


  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'operator', () ->
    _operator = null

    beforeEach () ->
      _operator = new XLF.Operator
      _operator.set 'id', 1
    it 'gets the operator id when operator is negated', () ->
      _operator.set 'is_negated', true

      expect(_operator.get_value()).toBe '-1'
    it 'gets the operator id when operator is not negated', () ->
      _operator.set 'is_negated', false

      expect(_operator.get_value()).toBe '1'

    describe 'serialize method', () ->
      it 'throws an exception when serialize is called', () ->
        expect(() -> _operator.serialize()).toThrow 'Not Implemented'

    describe 'get type method', () ->
      it 'gets the correct type', () ->
        expect(_operator.get_type()).toBe XLF.operator_types[0]

    describe 'get id method', () ->
      it 'gets the id', () ->
        expect(_operator.get_id()).toBe 1

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'empty operator', () ->
    it 'serializes to an empty string', () ->
      expect(new XLF.EmptyOperator().serialize()).toBe ''

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'skip logic operator', () ->
    it 'serializes the criterion', () ->
      operator = new XLF.SkipLogicOperator '='
      expect(operator.serialize 'test question', 'test response').toBe('${test question} = test response')

    it 'constructs criterion', () ->
      operator = new XLF.SkipLogicOperator '='
      expect(operator.get('is_negated')).toBeFalsy()
    it 'constructs negated criterion', () ->
      operator = new XLF.SkipLogicOperator '!='
      expect(operator.get('is_negated')).toBeTruthy()

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'text operator', () ->
    it 'serializes the criterion as text', () ->
      operator = new XLF.TextOperator '='
      expect(operator.serialize 'test question', 'test response').toBe("${test question} = 'test response'")

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'existence skip logic operator', ->
    it 'serializes the criterion', () ->
      operator = new XLF.ExistenceSkipLogicOperator '='
      expect(operator.serialize 'test question', 'test response').toBe("${test question} = ''")

    it 'constructs criterion', () ->
      operator = new XLF.ExistenceSkipLogicOperator '!='
      expect(operator.get('is_negated')).toBeFalsy()
    it 'constructs negated criterion', () ->
      operator = new XLF.ExistenceSkipLogicOperator '='
      expect(operator.get('is_negated')).toBeTruthy()

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'Response Model', () ->
    _response_model = null

    beforeEach () ->
      _response_model = new XLF.Model.ResponseModel()

    describe 'get type', () ->
      it 'gets the type name', () ->
        _response_model.set 'type', 'test'
        expect(_response_model.get_type()).toBe 'test'

    describe 'set value', () ->
      it 'sets the value correctly', () ->
        _response_model.set_value 'test'
        expect(_response_model.attributes.value).toBe 'test'

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'select multiple skip logic operator', () ->
    it 'serializes the criterion', () ->
      operator = new XLF.SelectMultipleSkipLogicOperator '='
      expect(operator.serialize 'test question', 'test response').toBe("selected(${test question}, 'test response')")

    it 'serializes negated criterion', () ->
      operator = new XLF.SelectMultipleSkipLogicOperator '!='
      expect(operator.serialize 'test question', 'test response').toEqual("not(selected(${test question}, 'test response'))")

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'date response value', () ->
    it 'sets state to valid when passed value is in date format', () ->
      response = new XLF.Model.DateResponseModel
      response.set_value("date('1234-12-12')")

      expect(response.isValid()).toBeTruthy()
      expect(response.get('value')).toBe("date('1234-12-12')")

    it 'sets state to invalid when passed value is not in date format', () ->
      response = new XLF.Model.DateResponseModel
      response.set_value('asdfasdf')

      expect(response.isValid()).toBeFalsy()
      expect(response.get('value')).toBeUndefined()

    it 'formats value when is raw date format', () ->
      response = new XLF.Model.DateResponseModel
      response.set_value('1234-12-12')

      expect(response.isValid()).toBeTruthy()
      expect(response.get('value')).toBe("date('1234-12-12')")

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'select response value', () ->
    it 'validates the current value against the option list of single select and multi select option lists ', () ->

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'integer response model', () ->
    _response_model = new XLF.Model.IntegerResponseModel()
    it 'sets state to valid when passed value is integer', () ->
      _response_model.set('value', 123, validate:true)

      expect(_response_model.isValid()).toBeTruthy()
    it 'sets state to invalid when passed value is decimal', () ->
      _response_model.set('value', 123.1234, validate:true)

      expect(_response_model.isValid()).toBeFalsy()
    it 'sets state to invalid when passed value is text', () ->
      _response_model.set('value', 'asdf', validate:true)

      expect(_response_model.isValid()).toBeFalsy()

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

  describe 'decimal response model', () ->
    _response_model = null
    beforeEach () ->
      _response_model = new XLF.Model.DecimalResponseModel()
    it 'sets state to valid when passed value is integer', () ->
      _response_model.set('value', 123, validate:true)

      expect(_response_model.isValid()).toBeTruthy()
    it 'sets state to invalid when passed value is decimal', () ->
      _response_model.set('value', 123.1234, validate:true)

      expect(_response_model.isValid()).toBeTruthy()
    it 'sets state to invalid when passed value is text', () ->
      _response_model.set('value', 'asdf', validate:true)

      expect(_response_model.isValid()).toBeFalsy()
    it 'parses decimals where comma is decimal separator', () ->
      _response_model.set_value('123,123')

      expect(_response_model.isValid()).toBeTruthy()
      expect(_response_model.get('value')).toBe(123.123)
    it 'parses decimals where comma is thousands and period is decimal separator', () ->
      _response_model.set_value('1,004.8')

      expect(_response_model.isValid()).toBeTruthy()
      expect(_response_model.get('value')).toBe(1004.8)
    it 'parses decimals where period is thousands and comma is decimal separator', () ->
      _response_model.set_value('1.001.004,8')

      expect(_response_model.isValid()).toBeTruthy()
      expect(_response_model.get('value')).toBe(1001004.8)
    it 'parses decimals where period is thousands and comma is decimal separator', () ->
      _response_model.set_value('-1.001.004,8')

      expect(_response_model.isValid()).toBeTruthy()
      expect(_response_model.get('value')).toBe(-1001004.8)
    it "doesn't execute when value is undefined", () ->
      _response_model.set_value()

      expect(_response_model.get('value')).toBeUndefined()
    it "doesn't execute when value is an empty string", () ->
      _response_model.set_value('')

      expect(_response_model.get('value')).toBeUndefined()
    it 'uses unaltered value when type is number', () ->
      _response_model.set_value(1)

      expect(_response_model.get('value')).toBe 1
    it 'strips spaces out of value', () ->
      _response_model.set_value('1  0 0 4,8')

      expect(_response_model.isValid()).toBeTruthy()
      expect(_response_model.get('value')).toBe(1004.8)
    it 'strips non breaking spaces out of value', () ->
      _response_model.set_value('1\u00A00\u00A00\u00A04,8')

      expect(_response_model.isValid()).toBeTruthy()
      expect(_response_model.get('value')).toBe(1004.8)


###******************************************************************************************************************************
***---------------------------------------------------------------------------------------------------------------------------***
******************************************************************************************************************************###

describe 'skip logic helpers', () ->
  beforeEach () ->
    @addMatchers toBeInstanceOf: (expectedInstance) ->
      actual = @actual
      notText = (if @isNot then " not" else "")
      @message = ->
        "Expected " + actual?.constructor.name + notText + " to be instance of " + expectedInstance.name

      return actual instanceof expectedInstance


  describe 'presenter', () ->
    _presenter = null
    _model = null
    _view = null
    _builder = null
    beforeEach () ->
      _model = sinon.stubObject XLF.SkipLogicCriterion
      _model._get_question.returns sinon.stubObject XLF.Row
      _model.get.withArgs('operator').returns(sinon.stubObject XLF.Operator)
      _model.get.withArgs('response_value').returns(sinon.stubObject XLF.Model.ResponseModel)

      _view = sinon.stubObject XLF.Views.SkipLogicCriterion
      _view.operator_picker_view = sinon.stubObject XLF.Views.OperatorPicker
      _view.response_value_view = sinon.stubObject XLF.Views.SkipLogicEmptyResponse

      _builder = sinon.stubObject XLF.SkipLogicBuilder
      _builder.build_response_view.returns(sinon.stubObject XLF.Views.SkipLogicEmptyResponse)
      _presenter = new XLF.SkipLogicPresenter _model, _view, _builder

    describe 'change question', () ->
      it 'changes the question in the model', () ->
        _presenter.change_question 'test'

        expect(_model.change_question).toHaveBeenCalledWith 'test'
      it 'attaches the response value model to the view', () ->
        response_view_stub = sinon.stubObject XLF.Views.SkipLogicEmptyResponse
        response_model_stub = sinon.stubObject XLF.Model.ResponseModel
        _model.get.withArgs('response_value').returns response_model_stub
        _builder.build_response_view.returns response_view_stub

        _presenter.change_question 'test'

        expect(response_view_stub.model).toBe response_model_stub
      it 'updates the operator view according to selected question type', () ->
        operator_view_stub = sinon.stubObject XLF.Views.OperatorPicker

        _model._get_question().get_type.returns 'test type'
        _builder.build_operator_view.withArgs('test type').returns operator_view_stub

        _presenter.change_question 'test'
        expect(_view.change_operator).toHaveBeenCalledWith operator_view_stub
      it "fills updated operator picker view's value", () ->
        _model.get('operator').get_value.returns -1
        _presenter.change_question 'test'

        expect(_view.operator_picker_view.fill_value).toHaveBeenCalledWith -1
      it "fills updated response view's value", () ->
        _model.get('response_value').get.withArgs('value').returns -1
        _presenter.change_question 'test'

        expect(_view.response_value_view.fill_value).toHaveBeenCalledWith -1

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'change operator', () ->
      it 'changes the operator model using the operator type id', () ->
        _presenter.change_operator 'test'

        expect(_model.change_operator).toHaveBeenCalledWith 'test'
      it 'binds the new response model to the response view', () ->
        response_view_stub = sinon.stubObject XLF.Views.SkipLogicEmptyResponse
        response_model_stub = sinon.stubObject XLF.Model.ResponseModel
        _model.get.withArgs('response_value').returns response_model_stub
        _builder.build_response_view.returns response_view_stub

        _presenter.change_operator 'test'

        expect(response_view_stub.model).toBe response_model_stub
      it 'fills the value into the updated response view', () ->
        _model.get('response_value').get.withArgs('value').returns -1
        _presenter.change_question 'test'

        expect(_view.response_value_view.fill_value).toHaveBeenCalledWith -1

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'change response value', () ->
      it 'changes the response value on the model', () ->
        _presenter.change_response 'test'

        expect(_model.change_response).toHaveBeenCalledWith 'test'

    describe 'render', () ->
      it 'attaches the view to the provided destination and fills in the defaults from the model', () ->

    describe 'serialize', () ->

  describe 'criterion builder helper', () ->
    _helper_factory = sinon.stubObject XLF.SkipLogicHelperFactory
    _model_factory = sinon.stubObject XLF.Model.SkipLogicFactory
    _view_factory = sinon.stubObject XLF.Views.SkipLogicViewFactory
    _question = null
    _survey = null
    _parser_stub = null
    _builder = null
    _view = null
    _presenter_stubs = null
    _delimiter_spy = null
    _facade = null

    beforeEach () ->
      _question = sinon.stubObject XLF.Row
      _survey = sinon.stubObject XLF.Survey
      _parser_stub = null
      _builder = sinon.stubObject(XLF.SkipLogicBuilder)
      _view = sinon.stubObject XLF.SkipLogicCriterionBuilderView
      _delimiter_spy =
        show: sinon.spy()
        hide: sinon.spy()

      _view_factory.create_criterion_builder_view.returns _view
      _view.render.returns _view
      _presenter_stubs = [
        sinon.stubObject XLF.SkipLogicPresenter
        sinon.stubObject XLF.SkipLogicPresenter
      ]

      _facade = new XLF.SkipLogicCriterionBuilderHelper(
        _presenter_stubs
        'and'
        _builder
        _view_factory
      )


    describe 'render', () ->
      _determine_criterion_visibility_spy = null
      beforeEach () ->
        _determine_criterion_visibility_spy = sinon.spy()
        _facade.determine_criterion_delimiter_visibility = _determine_criterion_visibility_spy
        _view.$.withArgs('.skiplogic__criterialist').returns 'test destination'
        _view.$.withArgs('.skiplogic__delimselect').returns _delimiter_spy
        _facade.render 'test'

      it 'renders the view', () ->
        expect(_view.render).toHaveBeenCalledOnce()
      it 'attaches root view to provided destination', () ->
        expect(_view.attach_to).toHaveBeenCalledWith 'test'
      it 'sets visibility of criterion delimiter', () ->
        expect(_determine_criterion_visibility_spy).toHaveBeenCalledOnce()
      it 'sets destination to views .skiplogic__criterialist element', () ->
        expect(_facade.destination).toBe 'test destination'
      it 'renders each presenter with destination taken from view', () ->
        expect(_presenter_stubs[0].render).toHaveBeenCalledWith 'test destination'
        expect(_presenter_stubs[1].render).toHaveBeenCalledWith 'test destination'
      it "sets $criterion_delimiter to view's .skiplogic__delimselect element", () ->
        expect(_facade.$criterion_delimiter).toBe _delimiter_spy

    describe 'determine_criterion_delimiter_visibility', () ->
      beforeEach () ->
        _facade.$criterion_delimiter = _delimiter_spy
      it 'shows the criterion delimiter when there is more than one presenter', () ->
        _facade.determine_criterion_delimiter_visibility()

        expect(_delimiter_spy.show).toHaveBeenCalledOnce()

      it 'hides the criterion delimiter when there is one presenter', () ->
        _facade.presenters = ['']
        _facade.determine_criterion_delimiter_visibility()

        expect(_delimiter_spy.hide).toHaveBeenCalledOnce()
    describe 'serialize', () ->
      it 'returns serialized criteria', () ->
        _presenter_stubs[0].serialize.returns 'one'
        _presenter_stubs[1].serialize.returns 'two'

        expect(_facade.serialize()).toBe 'one and two'
      it 'removes empty criteria', () ->
        _presenter_stubs[0].serialize.returns 'one'
        _presenter_stubs[1].serialize.returns ''

        expect(_facade.serialize()).toBe 'one'

    describe 'add_empty', () ->
      _empty_presenter_stub = null

      beforeEach () ->
        _empty_presenter_stub = sinon.stubObject XLF.SkipLogicPresenter
        _builder.build_empty_criterion_logic.returns _empty_presenter_stub
        _facade.presenters.push = sinon.spy()
        _facade.determine_criterion_delimiter_visibility = sinon.spy()
        _facade.destination = 'test detination'
        _facade.add_empty()

      it 'adds an empty presenter to the presenters object', () ->
        expect(_facade.presenters.push).toHaveBeenCalledWith _empty_presenter_stub

      it 'renders the empty presenter to the destination', () ->
        expect(_empty_presenter_stub.render).toHaveBeenCalledWith 'test detination'

      it 'calls determine_criterion_visibility', () ->
        expect(_facade.determine_criterion_delimiter_visibility).toHaveBeenCalledOnce()

    describe 'remove', () ->
      it 'removes presenter with model with passed id', () ->
        _presenter_stubs[0].model = cid: 1
        _presenter_stubs[1].model = cid: 2
        _facade.remove(1)

        expect(_presenter_stubs.length).toBe 1
        expect(_presenter_stubs[0].model.cid).toBe 2
    describe 'switch editing mode', () ->
      it 'returns a hand coded criteria with serialized version of criteria', () ->
        _builder.build_hand_code_criteria.withArgs('one and two').returns 'test hand coded criteria'
        _facade.serialize = sinon.stub().returns 'one and two'

        expect(_facade.switch_editing_mode()).toBe 'test hand coded criteria'

  describe 'hand code helper', () ->
    _view_factory = sinon.stubObject XLF.Views.SkipLogicViewFactory
    _builder = null
    _facade = null
    _view = null

    beforeEach () ->
      _view = sinon.stubObject XLF.SkipLogicHandCodeView
      _builder = sinon.stubObject(XLF.SkipLogicBuilder)
      _view_factory.create_hand_code_view.returns _view
      _view.render.returns _view
      _view.$.withArgs('.skiplogic-handcode__cancel').returns(click: sinon.spy())
      _facade = new XLF.SkipLogicHandCodeHelper(
        'test criteria'
        _builder
        _view_factory
        sinon.stubObject(XLF.SkipLogicHelperContext)
      )


    describe 'render', () ->
      _textarea_spy = null

      beforeEach () ->
        _textarea_spy = val: sinon.spy()

        _view.$.withArgs('textarea').returns _textarea_spy
        _facade.render 'test'

      it 'renders the view', () ->
        expect(_view.render).toHaveBeenCalledOnce()
      it 'attaches root view to provided destination', () ->
        expect(_view.attach_to).toHaveBeenCalledWith 'test'
      it "set the view's text area to the passed criteria", () ->
        expect(_textarea_spy.val).toHaveBeenCalledWith 'test criteria'
    describe 'serialize', () ->
      it "returns the value of the view's text area", ->
        textarea_stub = val: sinon.stub()
        _view.$.withArgs('textarea').returns textarea_stub
        textarea_stub.val.returns 'test criteria'
        expect(_facade.serialize()).toBe 'test criteria'

    describe 'switch editing mode', () ->
      it "returns an instance of a criterion builder facade", () ->
        _builder.build_criterion_builder.withArgs('test criteria').returns 'test facade'
        _facade.serialize = () -> 'test criteria'

        expect(_facade.switch_editing_mode()).toBe 'test facade'

    describe 'constructor', () ->

  describe 'mode selector helper', () ->
    describe 'render', () ->
      initialize_mode_selector_helper = () ->

        view_factory_stub = sinon.stubObject(XLF.Views.SkipLogicViewFactory)
        view_stub = sinon.stubObject(XLF.Views.SkipLogicPickerView)

        view_stub.render.returns view_stub
        view_factory_stub.create_skip_logic_picker_view.returns view_stub


        return new XLF.SkipLogicModeSelectorHelper(view_factory_stub)

      it 'renders the view', () ->
        helper = initialize_mode_selector_helper()
        helper.render('destination')

        expect(helper.view.render).toHaveBeenCalledOnce()
      it 'attaches the view to passed destination', () ->
        helper = initialize_mode_selector_helper()
        helper.render('destination')
        expect(helper.view.attach_to).toHaveBeenCalledWith('destination')

    describe 'serialize', () ->
      it 'returns an empty string', () ->
        helper = new XLF.SkipLogicModeSelectorHelper(sinon.stubObject(XLF.Views.SkipLogicViewFactory))

        result = helper.serialize()

        expect(result).toBe ''

  describe 'helper context', () ->
    initialize_helper_context = (serialized_criteria) ->
      return new XLF.SkipLogicHelperContext sinon.stubObject(XLF.Model.SkipLogicFactory), sinon.stubObject(XLF.Views.SkipLogicViewFactory), sinon.stubObject(XLF.SkipLogicBuilder), serialized_criteria
    describe 'render', () ->
      it 'calls render on inner state', () ->
        context = initialize_helper_context()

        state_spy = render: sinon.spy()

        context.state = state_spy

        destination_stub = empty: () ->

        context.render(destination_stub)

        expect(state_spy.render).toHaveBeenCalledWith destination_stub
    describe 'serialize', () ->
      it 'calls serialize on inner state', () ->
        context = initialize_helper_context()

        state_spy = serialize: sinon.spy()

        context.state = state_spy
        context.serialize()

        expect(state_spy.serialize).toHaveBeenCalledOnce()

    describe 'use criterion builder helper', () ->
      it 'switches inner state to criterion builder helper', () ->
        context = initialize_helper_context()
        context.state = serialize: sinon.stub().returns 'test'

        context.view_factory.create_criterion_builder_view.returns {}
        context.builder.build_criterion_builder.withArgs('test').returns('test presenter', 'and')

        context.use_criterion_builder_helper()

        expect(context.state).toBeInstanceOf XLF.SkipLogicCriterionBuilderHelper
      it 'sets state to null when builder can`t build criterion builder', () ->
        context = initialize_helper_context()
        context.state = serialize: sinon.stub().returns 'test'

        context.view_factory.create_criterion_builder_view.returns {}
        context.builder.build_criterion_builder.withArgs('test').returns(false)

        context.use_criterion_builder_helper()

        expect(context.state).toBeNull()
    describe 'use hand code helper', () ->
      it 'switches inner state to hand code helper', () ->
        context = initialize_helper_context()
        context.use_hand_code_helper()

        expect(context.state).toBeInstanceOf XLF.SkipLogicHandCodeHelper
    describe 'use mode selector helper', () ->
      it 'switches inner state to mode selector helper', () ->
        context = initialize_helper_context()
        context.use_mode_selector_helper()

        expect(context.state).toBeInstanceOf XLF.SkipLogicModeSelectorHelper
    describe 'constructor', () ->
      it 'defaults to mode selector helper', () ->
        context = initialize_helper_context()

        expect(context.state).toBeInstanceOf XLF.SkipLogicModeSelectorHelper
      it 'uses a mode selector helper when criteria is an empty string', () ->
        context = initialize_helper_context('')

        expect(context.state).toBeInstanceOf XLF.SkipLogicModeSelectorHelper
      it 'uses a criterion builder helper when serialized criteria can be parsed', () ->
        original_use_criterion_builder_helper = XLF.SkipLogicHelperContext.prototype.use_criterion_builder_helper
        XLF.SkipLogicHelperContext.prototype.use_criterion_builder_helper = () -> @state = 'test state'
        context = initialize_helper_context('asdf')
        expect(context.state).toBe 'test state'

        XLF.SkipLogicHelperContext.prototype.use_criterion_builder_helper = original_use_criterion_builder_helper
      it 'uses a hand code helper when passed criteria is unparseable', () ->
        original_use_criterion_builder_helper = XLF.SkipLogicHelperContext.prototype.use_criterion_builder_helper
        XLF.SkipLogicHelperContext.prototype.use_criterion_builder_helper = () -> @state = null
        context = initialize_helper_context('asdf')
        expect(context.state).toBeInstanceOf XLF.SkipLogicHandCodeHelper

        XLF.SkipLogicHelperContext.prototype.use_criterion_builder_helper = original_use_criterion_builder_helper

  describe 'skip logic builder', () ->
    initialize_builder = () ->
      model_factory = sinon.stubObject XLF.Model.SkipLogicFactory
      view_factory = sinon.stubObject XLF.Views.SkipLogicViewFactory
      survey = sinon.stubObject XLF.Survey
      current_question = sinon.stubObject XLF.Row
      helper_factory = sinon.stubObject XLF.SkipLogicHelperFactory

      new XLF.SkipLogicBuilder(model_factory, view_factory, survey, current_question, helper_factory)
    describe 'build', () ->
      it "returns a helper context", () ->
        relevant_stub = get: sinon.stub()
        relevant_stub.get.withArgs('value').returns('test criteria')

        builder = initialize_builder()

        builder.build_criterion_builder = sinon.stub()
        builder.build_criterion_builder.withArgs('test criteria').returns('test criterion builder')

        builder.current_question.get.withArgs('relevant').returns(relevant_stub)

        original_skip_logic_helper_context = XLF.SkipLogicHelperContext
        XLF.SkipLogicHelperContext =  () -> return
        result = builder.build()
        expect(result).toBeInstanceOf XLF.SkipLogicHelperContext

        XLF.SkipLogicHelperContext = original_skip_logic_helper_context

    describe 'build criterion builder', () ->
      _builder = null
      _parser_stub = null
      beforeEach () ->
        _builder = initialize_builder()
        _parser_stub = sinon.stub XLF, 'skipLogicParser'

        _builder.build_criterion_logic = sinon.stub()
        _builder.build_criterion_logic.onFirstCall().returns true
        _builder.build_criterion_logic.onSecondCall().returns 'test'

      afterEach () ->
        _parser_stub.restore()

      it 'returns empty criterion logic presenter when no criteria are passed', () ->
        _builder.build_empty_criterion_logic = sinon.stub().returns('test')
        result = _builder.build_criterion_builder ''

        expect(result).toEqual [['test'], 'and']
      it 'returns criterion logic presenter array when multiple criteria are passed', () ->
        _parser_stub.returns
          operator: 'and'
          criteria: [
            true
            'test'
          ]

        result = _builder.build_criterion_builder 'asdf'

        expect(result).toEqual [[true, 'test'], 'and']
      it 'filters out falsey criteria', () ->
        _parser_stub.returns
          operator: 'and'
          criteria: [
            true
            'test'
            false
          ]

        _builder.build_criterion_logic.onThirdCall().returns false

        result = _builder.build_criterion_builder 'asdf'

        expect(result).toEqual [[true, 'test'], 'and']
      it 'returns array with one criterion logic presenter when one criterion is passed', () ->
        _parser_stub.returns
          operator: 'and'
          criteria: [
            true
          ]

        result = _builder.build_criterion_builder 'asdf'

        expect(result).toEqual [[true], 'and']
      it 'returns empty criterion logic presenter when no passed criteria are valid', () ->
        _parser_stub.returns
          operator: 'and'
          criteria: [
            false
          ]
        _builder.build_empty_criterion_logic = sinon.stub().returns('empty')
        _builder.build_criterion_logic.onFirstCall().returns false

        result = _builder.build_criterion_builder 'asdf'

        expect(result).toEqual [['empty'], 'and']

      it 'returns false when skip logic parser can`t parse criteria', () ->
        _parser_stub.throws ''

        expect(_builder.build_criterion_builder 'asdf').toBe false

    describe 'build empty criterion logic', () ->
      it 'returns an empty criterion logic model', () ->
        builder = initialize_builder()

        criterion_model = new Backbone.Model()

        builder.model_factory.create_criterion_model.returns criterion_model

        builder.model_factory.create_operator.withArgs('empty').returns 'empty operator'

        builder.build_question_view = sinon.stub().returns 'question view'


        builder.view_factory.create_operator_picker.withArgs([]).returns 'operator picker'
        builder.view_factory.create_response_value_view.withArgs('empty').returns 'response value'

        builder.view_factory.create_criterion_view.withArgs('question view', 'operator picker', 'response value').returns 'criterion view'

        builder.helper_factory.create_presenter.withArgs(criterion_model, 'criterion view', builder).returns 'empty criterion presenter'

        result = builder.build_empty_criterion_logic()

        expect(result).toBe 'empty criterion presenter'

    describe 'build criterion logic', () ->
      it 'returns a criterion model based on passed criterion', () ->
        ###builder = initialize_builder()

        criterion =###
      it 'returns false when question no longer exists', () ->

    describe 'build hand code criteria', () ->
    describe 'build criterion builder', () ->

    describe 'build operator logic', () ->
    describe 'build operator model, () ->', () ->
    describe 'build operator view', () ->
    describe 'build question view', () ->
    describe 'build response view', () ->
    describe 'build response model', () ->
    describe 'questions', () ->
  describe 'helper factory', () ->
    _view_factory = sinon.stubObject XLF.Views.SkipLogicViewFactory
    beforeEach () ->
      @addMatchers toBeInstanceOf: (expectedInstance) ->
        actual = @actual
        notText = (if @isNot then " not" else "")
        @message = ->
          "Expected " + actual.constructor.name + notText + " is instance of " + expectedInstance.name

        actual instanceof expectedInstance
