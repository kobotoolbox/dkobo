global = @

describe "modules have been loaded into karma", ->
  it "including dkobo_xlform.js", ->
    expect(global.dkobo_xlform).toBeDefined()

  it "inlcuding angular", ->
    expect(global.angular).toBeDefined()

  it "inlcuding sinon", ->
    expect(global.sinon).toBeDefined()

