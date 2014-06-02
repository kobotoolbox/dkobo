specific_validator_tests = ->
  viewUtils = dkobo_xlform.view.utils

  describe "invalidChars", ->
    it "should return true when the passed test string contains no invalid chars", ->
      expect(viewUtils.Validator.__validators.invalidChars("asdf", "bxc")).toBeTruthy()

    it "should return false when the passed test string contains invalid chars", ->
      expect(viewUtils.Validator.__validators.invalidChars("asdf", "bxca")).toBeFalsy()

  describe "unique", ->
    it "should return true when the passed string is unique in the passed list", ->
      expect(viewUtils.Validator.__validators.unique("asdf", [
        "lkjh"
        "qwerty"
      ])).toBeTruthy()

    it "should return false when the passed string is not unique in the passed list", ->
      expect(viewUtils.Validator.__validators.unique("asdf", [
        "asdf"
        "lkjh"
      ])).toBeFalsy()
