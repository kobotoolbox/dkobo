validator_object_tests = ->
  validator = undefined
  validatorStub = undefined
  viewUtils = dkobo_xlform.view.utils

  beforeEach ->
    validator = viewUtils.Validator.create(validations: [
      name: "test"
      failureMessage: "did not pass test"
      args: ["test arg"]
    ])

  describe "validate method", ->
    it "should return true when value passes validation", ->
      validatorStub = sinon.stub()
      validatorStub.withArgs("test").returns true
      viewUtils.Validator.__validators.test = validatorStub
      expect(validator.validate("test")).toBe true
      expect(validatorStub).toHaveBeenCalledOnce()

    it "should return the validation failure message when value fails validation", ->
      validatorStub = sinon.stub()
      validatorStub.withArgs("test").returns false
      viewUtils.Validator.__validators.test = validatorStub
      expect(validator.validate("test")).toBe "did not pass test"
      expect(validatorStub).toHaveBeenCalledOnce()

    it "should consider additional arguments passed", ->
      validatorStub = sinon.stub()
      validatorStub.withArgs("test", "test arg").returns true
      viewUtils.Validator.__validators.test = validatorStub
      expect(validator.validate("test")).toBe true
      expect(validatorStub).toHaveBeenCalledOnce()
      expect(validatorStub).toHaveBeenCalledWith "test", "test arg"

    it "should instantiate the args array when no args are passed", ->
      validatorStub = sinon.stub()
      validatorStub.withArgs("test").returns true
      validator = viewUtils.Validator.create(validations: [
        name: "test"
        failureMessage: "did not pass test"
      ])
      viewUtils.Validator.__validators.test = validatorStub
      expect(validator.validate("test")).toBe true
      expect(validatorStub).toHaveBeenCalledOnce()
      expect(validatorStub).toHaveBeenCalledWith "test"