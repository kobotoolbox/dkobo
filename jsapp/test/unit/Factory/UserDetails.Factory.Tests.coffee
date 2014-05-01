user_details_factory_tests = ->
  it "should return the value of window.userDetails", ->
    window.userDetails = {}
    expect(userDetailsFactory()).toBe window.userDetails
