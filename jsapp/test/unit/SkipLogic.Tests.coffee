skip_logic_model = (dkobo_xlform)->
  $model  = dkobo_xlform.model
  $mRdsl  = $modelRowDetailsSkipLogic = $model.rowDetailsSkipLogic
  $vRdsl  = $viewRowDetailSkipLogic   = dkobo_xlform.view.rowDetailSkipLogic
  $slh    = $skipLogicHelpers         = dkobo_xlform.helper.skipLogic

  describe 'skip logic factory', () ->
    _factory = new $mRdsl.SkipLogicFactory()

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

      expect(operator).toBeInstanceOf $mRdsl.SkipLogicOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates a text skip logic operator', () ->
      operator = _factory.create_operator 'text', '=', 1

      expect(operator).toBeInstanceOf $mRdsl.TextOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates an existence skip logic operator', () ->
      operator = _factory.create_operator 'existence', '=', 1

      expect(operator).toBeInstanceOf $mRdsl.ExistenceSkipLogicOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates a select multiple skip logic operator', () ->
      operator = _factory.create_operator 'select_multiple', '=', 1

      expect(operator).toBeInstanceOf $mRdsl.SelectMultipleSkipLogicOperator
      expect(operator.get('id')).toBe 1
      expect(operator.get('symbol')).toBe '='

    it 'creates an empty skip logic operator', () ->
      operator = _factory.create_operator 'empty', '=', 1

      expect(operator).toBeInstanceOf $mRdsl.EmptyOperator
      expect(operator.get('id')).toBe 0
      expect(operator.get('symbol')).toBeUndefined()

    it 'creates a criterion model', () ->
      criterion = _factory.create_criterion_model 'test question', 'test operator'

      expect(criterion).toBeInstanceOf $mRdsl.SkipLogicCriterion

    it 'creates a text response model', () ->
      expect(_factory.create_response_model 'text').toBeInstanceOf $mRdsl.ResponseModel

    it 'creates an integer response model', () ->
      expect(_factory.create_response_model 'integer').toBeInstanceOf $mRdsl.IntegerResponseModel

    it 'creates a decimal response model', () ->
      expect(_factory.create_response_model 'decimal').toBeInstanceOf $mRdsl.DecimalResponseModel

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

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
      _criterion = new $mRdsl.SkipLogicCriterion

      _operator =
        serialize: sinon.stub().withArgs('test question', 'test value').returns 'test criterion'
      _factory = sinon.stub()

    #*********************************************************************
    #**----------------------------------------------------------------***
    #********************************************************************#

    describe 'serialize method', () ->
      beforeEach () ->
        _criterion._get_question = sinon.stub().returns
          get: sinon.stub().returns(get: sinon.stub().returns 'test question')
          getValue: (what) -> 'test name'
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

    #*********************************************************************
    #**----------------------------------------------------------------***
    #********************************************************************#


    describe 'change question', () ->
      beforeEach () ->
        _criterion.survey = _survey
        _criterion._get_question = sinon.stub().returns(_isSelectQuestion: sinon.stub().returns(false), get_type: sinon.stub().returns(response_type: 'text', operators: [1, 2]))
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
        _criterion._get_question = sinon.stub().withArgs('operator in question type').returns(_isSelectQuestion: sinon.stub().returns(false), get_type: () -> {operators: [-1], name: 'test'})
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
        get_question_stub.returns _isSelectQuestion: sinon.stub().returns(false), get_type: () -> {operators: [-1], name: 'test'}

        _criterion._get_question = get_question_stub
        _criterion.change_question('test')

        expect(_criterion.change_operator).toHaveBeenCalledWith -1

    #*********************************************************************
    #**----------------------------------------------------------------***
    #********************************************************************#

    describe 'change operator', () ->
      question_stub = null
      beforeEach () ->
        question_stub =
          get_type: sinon.stub().returns(response_type: 'text', operators: [1, 2], equality_operator_type: 'text')
          _isSelectQuestion: () -> false

        _criterion.factory = create_operator: sinon.stub().withArgs('existence', '=', 1).returns 'test operator'
        _criterion._get_question = sinon.stub().returns(question_stub)

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

    #*********************************************************************
    #**----------------------------------------------------------------***
    #********************************************************************#

    describe 'set option names', () ->
      it 'sets option names to sluggified version of their labels', () ->
        options = [
          new Backbone.Model(label: 'Option 1')
          new Backbone.Model(label: 'Option 2')
        ]

        _criterion.set_option_names options

        expect(options[0].get('name')).toBe 'option_1'
        expect(options[1].get('name')).toBe 'option_2'

    #*********************************************************************
    #**----------------------------------------------------------------***
    #********************************************************************#

    describe 'change response value', () ->
      __getter = null
      beforeEach () ->
        response_model = set_value: sinon.spy()
        response_value_getter = sinon.stub()
        response_value_getter.withArgs('type').returns('none')
        response_value_getter.withArgs('value').returns('test')
        response_value_getter.withArgs('cid').returns('test')
        response_model.get = response_value_getter
        response_model.set = sinon.spy()
        _criterion.set 'operator', get_type: () -> {}
        _question_getter = sinon.stub()

        _criterion._get_question = sinon.stub().returns(get_type: sinon.stub().returns(response_type: 'text'), getList: () -> options: models: [{get: sinon.stub().returns('test option'), cid: 'test option'}, {get: sinon.stub().returns('test option 2'), cid: 'test option 2'}, {get: sinon.stub().returns('test option 3'), cid: 'test option 3'}])

        _criterion.factory = create_response_model: sinon.stub().returns set_value: sinon.spy(), set: sinon.spy(), get: response_value_getter
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
        _criterion.get('response_value').get.withArgs('cid').returns('test option 2')

        _criterion.change_response 'test'

        expect(_criterion.get('response_value').set_value).toHaveBeenCalledWith 'test option 2'

      it 'uses passed value when in choice list', () ->
        _criterion.get_correct_type = sinon.stub().returns('dropdown')
        _criterion.get('response_value').get.withArgs('value').returns('test option 2')

        _criterion.change_response 'test option 3'

        expect(_criterion.get('response_value').set_value).toHaveBeenCalledWith 'test option 3'


  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#


  describe 'operator', () ->
    _operator = null

    beforeEach () ->
      _operator = new $mRdsl.Operator
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
        expect(_operator.get_type()).toBe $slh.operator_types[0]

    describe 'get id method', () ->
      it 'gets the id', () ->
        expect(_operator.get_id()).toBe 1

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'empty operator', () ->
    it 'serializes to an empty string', () ->
      expect(new $mRdsl.EmptyOperator().serialize()).toBe ''

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'skip logic operator', () ->
    it 'serializes the criterion', () ->
      operator = new $mRdsl.SkipLogicOperator '='
      expect(operator.serialize 'test question', 'test response').toBe('${test question} = test response')

    it 'constructs criterion', () ->
      operator = new $mRdsl.SkipLogicOperator '='
      expect(operator.get('is_negated')).toBeFalsy()
    it 'constructs negated criterion', () ->
      operator = new $mRdsl.SkipLogicOperator '!='
      expect(operator.get('is_negated')).toBeTruthy()

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'text operator', () ->
    it 'serializes the criterion as text', () ->
      operator = new $mRdsl.TextOperator '='
      expect(operator.serialize 'test question', 'test response').toBe("${test question} = 'test response'")

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'existence skip logic operator', ->
    it 'serializes the criterion', () ->
      operator = new $mRdsl.ExistenceSkipLogicOperator '='
      expect(operator.serialize 'test question', 'test response').toBe("${test question} = ''")

    it 'constructs criterion', () ->
      operator = new $mRdsl.ExistenceSkipLogicOperator '!='
      expect(operator.get('is_negated')).toBeFalsy()
    it 'constructs negated criterion', () ->
      operator = new $mRdsl.ExistenceSkipLogicOperator '='
      expect(operator.get('is_negated')).toBeTruthy()

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'Response Model', () ->
    _response_model = null

    beforeEach () ->
      _response_model = new $mRdsl.ResponseModel()

    describe 'get type', () ->
      it 'gets the type name', () ->
        _response_model.set 'type', 'test'
        expect(_response_model.get_type()).toBe 'test'

    describe 'set value', () ->
      it 'sets the value correctly', () ->
        _response_model.set_value 'test'
        expect(_response_model.attributes.value).toBe 'test'

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'select multiple skip logic operator', () ->
    it 'serializes the criterion', () ->
      operator = new $mRdsl.SelectMultipleSkipLogicOperator '='
      expect(operator.serialize 'test question', 'test response').toBe("selected(${test question}, 'test response')")

    it 'serializes negated criterion', () ->
      operator = new $mRdsl.SelectMultipleSkipLogicOperator '!='
      expect(operator.serialize 'test question', 'test response').toEqual("not(selected(${test question}, 'test response'))")

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'date response value', () ->
    it 'sets state to valid when passed value is in date format', () ->
      response = new $mRdsl.DateResponseModel
      response.set_value("date('1234-12-12')")

      expect(response.isValid()).toBeTruthy()
      expect(response.get('value')).toBe("date('1234-12-12')")

    it 'sets state to invalid when passed value is not in date format', () ->
      response = new $mRdsl.DateResponseModel
      response.set_value('asdfasdf')

      expect(response.isValid()).toBeFalsy()
      expect(response.get('value')).toBeUndefined()

    it 'formats value when is raw date format', () ->
      response = new $mRdsl.DateResponseModel
      response.set_value('1234-12-12')

      expect(response.isValid()).toBeTruthy()
      expect(response.get('value')).toBe("date('1234-12-12')")

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'select response value', () ->
    it 'validates the current value against the option list of single select and multi select option lists ', () ->

  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'integer response model', () ->
    _response_model = new $mRdsl.IntegerResponseModel()
    it 'sets state to valid when passed value is integer', () ->
      _response_model.set('value', 123, validate:true)

      expect(_response_model.isValid()).toBeTruthy()
    it 'sets state to invalid when passed value is decimal', () ->
      _response_model.set('value', 123.1234, validate:true)

      expect(_response_model.isValid()).toBeFalsy()

    it 'sets state to invalid when passed value is text', () ->
      _response_model.set('value', 'asdf', validate:true)

      expect(_response_model.isValid()).toBeFalsy()

    it 'clears model on empty string', () ->
      _response_model.set_value('')

      expect(_response_model.isValid()).toBeFalsy()
      expect(_response_model.get('value')).toBeUndefined()
  #*********************************************************************
  #**----------------------------------------------------------------***
  #********************************************************************#

  describe 'decimal response model', () ->
    _response_model = null
    beforeEach () ->
      _response_model = new $mRdsl.DecimalResponseModel()
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
    it 'clears model on empty string', () ->
      _response_model.set_value('')

      expect(_response_model.isValid()).toBeFalsy()
      expect(_response_model.get('value')).toBeUndefined()

#*********************************************************************
#**----------------------------------------------------------------***
#********************************************************************#

skip_logic_helpers = (dkobo_xlform) ->
  $model  = dkobo_xlform.model
  $mRdsl  = $modelRowDetailsSkipLogic = $model.rowDetailsSkipLogic
  $vRdsl  = $viewRowDetailSkipLogic   = dkobo_xlform.view.rowDetailSkipLogic
  $slh    = $skipLogicHelpers         = dkobo_xlform.helper.skipLogic

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
    _view_factory = null
    beforeEach () ->
      _model = sinon.stubObject $mRdsl.SkipLogicCriterion
      row_stub = sinon.stubObject $model.Row
      row_stub._isSelectQuestion = () -> false

      _model._get_question.returns row_stub

      _model.get.withArgs('operator').returns(sinon.stubObject $mRdsl.Operator)
      _model.get.withArgs('response_value').returns(sinon.stubObject $mRdsl.ResponseModel)

      _view = sinon.stubObject $mRdsl.SkipLogicCriterion
      _view.operator_picker_view = sinon.stubObject $vRdsl.OperatorPicker
      _view.response_value_view = sinon.stubObject $vRdsl.SkipLogicEmptyResponse

      _view.attach_operator = sinon.spy()
      _view.attach_response = sinon.spy()

      _builder = sinon.stubObject $slh.SkipLogicBuilder
      _builder.current_question =
        get: sinon.stub()
      _builder.current_question.get.returns(
        set: sinon.spy()
      )

      _view_factory = sinon.stubObject $vRdsl.SkipLogicViewFactory
      response_view_stub = sinon.stubObject $vRdsl.SkipLogicEmptyResponse
      response_view_stub.$el = trigger: sinon.stub()
      _view_factory.create_response_value_view.returns(response_view_stub)

      _presenter = new $slh.SkipLogicPresenter _model, _view, _builder, null, _view_factory
      _presenter.determine_add_new_criterion_visibility = sinon.spy()
      _presenter.serialize_all = sinon.spy()
      _presenter.dispatcher = _.clone Backbone.Events

    describe 'change question', () ->
      it 'changes the question in the model', () ->
        _presenter.change_question 'test'

        expect(_model.change_question).toHaveBeenCalledWith 'test'
      it 'attaches the response value model to the view', () ->
        response_view_stub = sinon.stubObject $vRdsl.SkipLogicEmptyResponse
        response_view_stub.$el = trigger: sinon.stub()
        response_model_stub = sinon.stubObject $mRdsl.ResponseModel
        _model.get.withArgs('response_value').returns response_model_stub
        _view_factory.create_response_value_view.returns response_view_stub

        _presenter.change_question 'test'

        expect(response_view_stub.model).toBe response_model_stub
      it 'updates the operator view according to selected question type', () ->
        operator_view_stub = sinon.stubObject $vRdsl.OperatorPicker

        _model._get_question().get_type.returns 'test type'
        _view_factory.create_operator_picker.withArgs('test type').returns operator_view_stub

        _presenter.change_question 'test'
        expect(_view.change_operator).toHaveBeenCalledWith operator_view_stub
      it "fills updated operator picker view's value", () ->
        _model.get('operator').get_value.returns -1
        _presenter.change_question 'test'

        expect(_view.operator_picker_view.val).toHaveBeenCalledWith -1
      it "fills updated response view's value", () ->
        _model.get('response_value').get.withArgs('value').returns -1
        _presenter.change_question 'test'

        expect(_view.response_value_view.val).toHaveBeenCalledWith -1

    #*********************************************************************
    #**----------------------------------------------------------------***
    #********************************************************************#

    describe 'change operator', () ->
      beforeEach () ->
        _model.get('operator').get_type = () -> {}
      it 'changes the operator model using the operator type id', () ->
        _presenter.change_operator 'test'

        expect(_model.change_operator).toHaveBeenCalledWith 'test'
      it 'binds the new response model to the response view', () ->
        response_view_stub = sinon.stubObject $vRdsl.SkipLogicEmptyResponse
        response_view_stub.$el = trigger: sinon.stub()
        response_model_stub = sinon.stubObject $mRdsl.ResponseModel
        _model.get.withArgs('response_value').returns response_model_stub

        _view_factory.create_response_value_view.returns response_view_stub

        _presenter.change_operator 'test'

        expect(response_view_stub.model).toBe response_model_stub
      it 'fills the value into the updated response view', () ->
        _model.get('response_value').get.withArgs('value').returns -1
        _presenter.change_question 'test'

        expect(_view.response_value_view.val).toHaveBeenCalledWith -1

    #*********************************************************************
    #**----------------------------------------------------------------***
    #********************************************************************#

    describe 'change response value', () ->
      it 'changes the response value on the model', () ->
        _presenter.change_response 'test'

        expect(_model.change_response).toHaveBeenCalledWith 'test'

    describe 'render', () ->
      it 'attaches the view to the provided destination and fills in the defaults from the model', () ->

    describe 'serialize', () ->

  describe 'criterion builder helper', () ->
    _helper_factory = sinon.stubObject $slh.SkipLogicHelperFactory
    _model_factory = sinon.stubObject $mRdsl.SkipLogicFactory
    _view_factory = sinon.stubObject $vRdsl.SkipLogicViewFactory
    _question = null
    _survey = null
    _parser_stub = null
    _builder = null
    _view = null
    _presenter_stubs = null
    _delimiter_spy = null
    _facade = null

    beforeEach () ->
      _question = sinon.stubObject $model.Row
      _survey = sinon.stubObject $model.Survey
      _parser_stub = null
      _builder = sinon.stubObject($slh.SkipLogicBuilder)
      _builder.survey =
        on: sinon.spy()
        off: sinon.spy()
      _builder.current_question = questions: 'test question'
      _view = sinon.stubObject $vRdsl.SkipLogicCriterionBuilderView
      _delimiter_spy =
        show: sinon.spy()
        hide: sinon.spy()

      _view_factory.create_criterion_builder_view.returns _view
      _view.render.returns _view
      _presenter_stubs = [
        sinon.stubObject $slh.SkipLogicPresenter
        sinon.stubObject $slh.SkipLogicPresenter
      ]

      for presenter in _presenter_stubs
        presenter.model = _get_question: sinon.stub()

      _facade = new $slh.SkipLogicCriterionBuilderHelper(
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
        _empty_presenter_stub = sinon.stubObject $slh.SkipLogicPresenter
        _builder.build_empty_criterion.returns _empty_presenter_stub
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
        _presenter_stubs[0].view = $el: remove: sinon.spy()
        _presenter_stubs[1].view = $el: remove: sinon.spy()
        _facade.determine_add_new_criterion_visibility = sinon.spy()

        _facade.remove(1)

        expect(_presenter_stubs.length).toBe 1
        expect(_presenter_stubs[0].model.cid).toBe 2

  describe 'hand code helper', () ->


  describe 'mode selector helper', () ->
    describe 'serialize', () ->
      it 'returns an empty string', () ->
        helper = new $slh.SkipLogicModeSelectorHelper(sinon.stubObject($vRdsl.SkipLogicViewFactory))

        result = helper.serialize()

        expect(result).toBe ''

  describe 'helper context', () ->
    initialize_helper_context = (serialized_criteria) ->
      helper_factory = sinon.stubObject($slh.SkipLogicHelperFactory)
      helper_factory.survey =
        off: sinon.spy()
      return new $slh.SkipLogicHelperContext sinon.stubObject($mRdsl.SkipLogicFactory), sinon.stubObject($vRdsl.SkipLogicViewFactory), helper_factory, serialized_criteria
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

    describe 'use hand code helper', () ->
      it 'switches inner state to hand code helper', () ->
        context = initialize_helper_context()
        context.use_hand_code_helper()

        expect(context.state).toBeInstanceOf $slh.SkipLogicHandCodeHelper
    describe 'use mode selector helper', () ->
      it 'switches inner state to mode selector helper', () ->
        context = initialize_helper_context()
        context.use_mode_selector_helper()

        expect(context.state).toBeInstanceOf $slh.SkipLogicModeSelectorHelper
    describe 'constructor', () ->
      it 'defaults to mode selector helper', () ->
        context = initialize_helper_context()

        expect(context.state).toBeInstanceOf $slh.SkipLogicModeSelectorHelper
      it 'uses a mode selector helper when criteria is an empty string', () ->
        context = initialize_helper_context('')

        expect(context.state).toBeInstanceOf $slh.SkipLogicModeSelectorHelper
      it 'uses a criterion builder helper when serialized criteria can be parsed', () ->
        original_use_criterion_builder_helper = $slh.SkipLogicHelperContext.prototype.use_criterion_builder_helper
        $slh.SkipLogicHelperContext.prototype.use_criterion_builder_helper = () -> @state = 'test state'
        context = initialize_helper_context('asdf')
        expect(context.state).toBe 'test state'

        $slh.SkipLogicHelperContext.prototype.use_criterion_builder_helper = original_use_criterion_builder_helper
      it 'uses a hand code helper when passed criteria is unparseable', () ->
        original_use_criterion_builder_helper = $slh.SkipLogicHelperContext.prototype.use_criterion_builder_helper
        $slh.SkipLogicHelperContext.prototype.use_criterion_builder_helper = () -> @state = null
        context = initialize_helper_context('asdf')
        expect(context.state).toBeInstanceOf $slh.SkipLogicHandCodeHelper

        $slh.SkipLogicHelperContext.prototype.use_criterion_builder_helper = original_use_criterion_builder_helper

  describe 'skip logic builder', () ->
    initialize_builder = () ->
      model_factory = sinon.stubObject $mRdsl.SkipLogicFactory
      view_factory = sinon.stubObject $vRdsl.SkipLogicViewFactory
      survey = sinon.stubObject $model.Survey
      current_question = sinon.stubObject $model.Row
      helper_factory = sinon.stubObject $slh.SkipLogicHelperFactory

      new $slh.SkipLogicBuilder(model_factory, view_factory, survey, current_question, helper_factory)

    describe 'build criterion builder', () ->
      _builder = null
      _parser_stub = null
      beforeEach () ->
        _builder = initialize_builder()
        _parser_stub = sinon.stub _builder, '_parse_skip_logic_criteria'

        _builder.build_criterion = sinon.stub()
        _builder.build_criterion.onFirstCall().returns true
        _builder.build_criterion.onSecondCall().returns 'test'

      afterEach () ->
        _parser_stub.restore()

      it 'returns empty criterion logic presenter when no criteria are passed', () ->
        _builder.build_empty_criterion = sinon.stub().returns('test')
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

        _builder.build_criterion.onThirdCall().returns false

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
        _builder.build_empty_criterion = sinon.stub().returns('empty')
        _builder.build_criterion.onFirstCall().returns false

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

        builder.view_factory.create_question_picker = sinon.stub().returns 'question view'


        builder.view_factory.create_operator_picker.withArgs(null).returns 'operator picker'
        builder.view_factory.create_response_value_view.withArgs(null).returns 'response value'

        builder.view_factory.create_criterion_view.withArgs('question view', 'operator picker', 'response value').returns 'criterion view'

        builder.helper_factory.create_presenter.withArgs(criterion_model, 'criterion view').returns 'empty criterion presenter'

        result = builder.build_empty_criterion()

        expect(result).toBe 'empty criterion presenter'

    describe 'build criterion logic', () ->
      it 'returns a criterion model based on passed criterion', () ->
        # builder = initialize_builder()
        #
        # criterion =
      it 'returns false when question no longer exists', () ->

    describe 'build hand code criteria', () ->
    describe 'build criterion builder', () ->

    describe 'build operator logic', () ->
    describe 'build operator model', () ->
    describe 'build operator view', () ->
    describe 'build question view', () ->
    describe 'build response view', () ->
    describe 'build response model', () ->
    describe 'questions', () ->
  describe 'helper factory', () ->
    _view_factory = sinon.stubObject $vRdsl.SkipLogicViewFactory
    beforeEach () ->
      @addMatchers toBeInstanceOf: (expectedInstance) ->
        actual = @actual
        notText = (if @isNot then " not" else "")
        @message = ->
          "Expected " + actual.constructor.name + notText + " is instance of " + expectedInstance.name

        actual instanceof expectedInstance

skip_logic_views = (dkobo_xlform) ->
  $model  = dkobo_xlform.model
  $mRdsl  = $modelRowDetailsSkipLogic = $model.rowDetailsSkipLogic
  $vRdsl  = $viewRowDetailSkipLogic   = dkobo_xlform.view.rowDetailSkipLogic
  $slh    = $skipLogicHelpers         = dkobo_xlform.helper.skipLogic

describe 'skip logic model', -> skip_logic_model.call(@, dkobo_xlform)
describe 'skip logic helpers', -> skip_logic_helpers.call(@, dkobo_xlform)
describe 'skip logic views', -> skip_logic_views.call(@, dkobo_xlform)
