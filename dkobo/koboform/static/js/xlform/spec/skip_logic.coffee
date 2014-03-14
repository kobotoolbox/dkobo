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

  ###******************************************************************************************************************************
  ***---------------------------------------------------------------------------------------------------------------------------***
  ******************************************************************************************************************************###

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
  describe 'presenter', () ->
    describe 'change question', () ->
      it 'changes the question in the model', () ->
      it 'changes the response model to the question types model', () ->
      it 'attaches the response value model to the view', () ->
      it 'updates the operator view according to selected question type', () ->
      it 'updates the response view if operator is changed', () ->
      it 'changes the operator model if current operator not in new operator list', () ->
      it 'changes the response value on the criterion model', () ->
      it 'fills the value into the updated operator picker view', () ->
      it 'fills the value into the updated response view', () ->

      it 'updates the builders question type', () ->
      it 'rebinds the question to itself', () ->
      it 'updates the builders operator type', () ->

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'change operator', () ->
      it 'changes the response model to the question types model', () ->
      it 'changes the operator model using the operator type id', () ->
      it 'binds the new response model to the response view', () ->
      it 'fills the value into the updated response view', () ->

      it 'updates the builders operator type', () ->

    ###******************************************************************************************************************************
    ***---------------------------------------------------------------------------------------------------------------------------***
    ******************************************************************************************************************************###

    describe 'change response value', () ->
      it 'changes the response value on the model', () ->
    describe 'constructor', () ->
      it 'binds itself to the criterion view', () ->
      it 'binds the question to itself', () ->
    describe 'render', () ->
      it 'attaches the view to the provided destination and fills in the defaults from the model', () ->

    describe 'serialize', () ->

  describe 'criterion builder facade', () ->
    describe 'render', () ->
      it 'attaches the root view to the provided destination', () ->

      it 'sets visibility of criterion delimiter', () ->

    describe 'serialize', () ->
    describe 'switch editing mode', () ->
    describe 'constructor', () ->

    describe 'add empty', () ->
    describe 'remove', () ->

    describe 'determine criterion delimiter visibility', () ->
      it 'shows the criterion delimiter picker when there is more than 1 criteria in the list', () ->
      it 'hides the criterion delimiter picker when there is 1 or less criteria in the list', () ->

  describe 'hand code facade', () ->
    describe 'render', () ->
    describe 'serialize', () ->
    describe 'switch editing mode', () ->
    describe 'constructor', () ->

    describe 'skip logic builder', () ->
    describe 'build', () ->

    describe 'build empty criterion logic', () ->
    describe 'build criterion logic', () ->

    describe 'build hand code criteria', () ->
    describe 'build criterion builder', () ->

    describe 'build operator logic', () ->
    describe 'build operator model, () ->', () ->
    describe 'build operator view', () ->
    describe 'build question view', () ->
    describe 'build response view', () ->
    describe 'build response model', () ->
    describe 'questions', () ->
