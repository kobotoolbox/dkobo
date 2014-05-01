validator_tests = ->
  viewUtils = dkobo_xlform.view.utils
  describe "Specific validators", ->
    describe "invalidChars", ->
      it "should return true when the passed test string contains no invalid chars", ->
        expect(viewUtils.Validator.__validators.invalidChars("asdf", "bxc")).toBeTruthy()
        return

      it "should return false when the passed test string contains invalid chars", ->
        expect(viewUtils.Validator.__validators.invalidChars("asdf", "bxca")).toBeFalsy()
        return

      return

    describe "unique", ->
      it "should return true when the passed string is unique in the passed list", ->
        expect(viewUtils.Validator.__validators.unique("asdf", [
          "lkjh"
          "qwerty"
        ])).toBeTruthy()
        return

      it "should return false when the passed string is not unique in the passed list", ->
        expect(viewUtils.Validator.__validators.unique("asdf", [
          "asdf"
          "lkjh"
        ])).toBeFalsy()
        return

      return

    return

  describe "Validator Object", ->
    validator = undefined
    validatorStub = undefined
    beforeEach ->
      validator = viewUtils.Validator.create(validations: [
        name: "test"
        failureMessage: "did not pass test"
        args: ["test arg"]
      ])
      return

    describe "validate method", ->
      it "should return true when value passes validation", ->
        validatorStub = sinon.stub()
        validatorStub.withArgs("test").returns true
        viewUtils.Validator.__validators.test = validatorStub
        expect(validator.validate("test")).toBe true
        expect(validatorStub).toHaveBeenCalledOnce()
        return

      it "should return the validation failure message when value fails validation", ->
        validatorStub = sinon.stub()
        validatorStub.withArgs("test").returns false
        viewUtils.Validator.__validators.test = validatorStub
        expect(validator.validate("test")).toBe "did not pass test"
        expect(validatorStub).toHaveBeenCalledOnce()
        return

      it "should consider additional arguments passed", ->
        validatorStub = sinon.stub()
        validatorStub.withArgs("test", "test arg").returns true
        viewUtils.Validator.__validators.test = validatorStub
        expect(validator.validate("test")).toBe true
        expect(validatorStub).toHaveBeenCalledOnce()
        expect(validatorStub).toHaveBeenCalledWith "test", "test arg"
        return

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
        return

      return

    return

  return