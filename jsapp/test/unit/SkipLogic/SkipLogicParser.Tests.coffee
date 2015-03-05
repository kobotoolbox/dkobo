#global XLF

#global describe

#global it

#global expect
skip_logic_parser_tests = ->

  # to get tests passing as they were, wrap the skipLogicParser in XLF object.
  XLF = skipLogicParser: dkobo_xlform.model.utils.skipLogicParser
  it "parses a single not-equals clause", ->
    expect(XLF.skipLogicParser("${question_name}   !=   'value')")).toEqual criteria: [
      name: "question_name"
      operator: "resp_notequals"
      response_value: "value"
    ]

  it "parses a single equals clause", ->
    expect(XLF.skipLogicParser("${question_name}   =   'value')")).toEqual criteria: [
      name: "question_name"
      operator: "resp_equals"
      response_value: "value"
    ]

  it "parses a decimal equals clause", ->
    expect(XLF.skipLogicParser("${question_name} = 123.123")).toEqual criteria: [
      name: "question_name"
      operator: "resp_equals"
      response_value: "123.123"
    ]

  it "parses a negative number equals clause", ->
    expect(XLF.skipLogicParser("${question_name} = -1")).toEqual criteria: [
      name: "question_name"
      operator: "resp_equals"
      response_value: "-1"
    ]

  it "parses a date equals clause", ->
    expect(XLF.skipLogicParser("${question} = date('1234-12-12')")).toEqual criteria: [
      name: "question"
      operator: "resp_equals"
      response_value: "1234-12-12"
    ]

  it "parses a single equals clause without padding between operands", ->
    expect(XLF.skipLogicParser("${question_name}='value')")).toEqual criteria: [
      name: "question_name"
      operator: "resp_equals"
      response_value: "value"
    ]

  it "parses a single answered clause", ->
    expect(XLF.skipLogicParser("${question_name}   !=   ''")).toEqual criteria: [
      name: "question_name"
      operator: "ans_notnull"
    ]

  it "parses a single not-answered clause", ->
    expect(XLF.skipLogicParser("${question_name}   =   ''")).toEqual criteria: [
      name: "question_name"
      operator: "ans_null"
    ]

  it "parses multiple AND separated clauses", ->
    expect(XLF.skipLogicParser("${question_name} != 'value' AND ${question_name} != ''")).toEqual
      criteria: [
        {
          name: "question_name"
          operator: "resp_notequals"
          response_value: "value"
        }
        {
          name: "question_name"
          operator: "ans_notnull"
        }
      ]
      operator: "AND"

  it "parses multiple OR separated clauses", ->
    expect(XLF.skipLogicParser("${question_name} != 'value' OR ${question_name} != ''")).toEqual
      criteria: [
        {
          name: "question_name"
          operator: "resp_notequals"
          response_value: "value"
        }
        {
          name: "question_name"
          operator: "ans_notnull"
        }
      ]
      operator: "OR"

  it "throws an error on multiple clauses with different join clauses", ->
    expect(->
      XLF.skipLogicParser "${question_name} != 'value' OR ${question_name} != NULL AND ${question_name} != NULL "
    ).toThrow()

  it "parses a single multiselect clause", ->
    expect(XLF.skipLogicParser("selected(${question_name}, 'value')")).toEqual criteria: [
      name: "question_name"
      operator: "multiplechoice_selected"
      response_value: "value"
    ]

  it "parses multiple multiselect clauses", ->
    expect(XLF.skipLogicParser("selected(${question_name}, 'value') OR selected(${question_name2}, 'value2')")).toEqual
      criteria: [
        {
          name: "question_name"
          operator: "multiplechoice_selected"
          response_value: "value"
        }
        {
          name: "question_name2"
          operator: "multiplechoice_selected"
          response_value: "value2"
        }
      ]
      operator: "OR"

  it "parses a single negated multiselect clause", ->
    expect(XLF.skipLogicParser("not(selected(${question_name}, 'value'))")).toEqual criteria: [
      name: "question_name"
      operator: "multiplechoice_notselected"
      response_value: "value"
    ]

  it "parses multiple negated multiselect clauses", ->
    expect(XLF.skipLogicParser("not(selected(${question_name}, 'value')) OR not(selected(${question_name2}, 'value2'))")).toEqual
      criteria: [
        {
          name: "question_name"
          operator: "multiplechoice_notselected"
          response_value: "value"
        }
        {
          name: "question_name2"
          operator: "multiplechoice_notselected"
          response_value: "value2"
        }
      ]
      operator: "OR"

  it "throws an error when the passed clause is invalid", ->
    expect(->
      XLF.skipLogicParser "invalid clause"
    ).toThrow new Error("criterion not recognized: \"invalid clause\"")

  it "doesn`t match and and or in names", ->
    expect(XLF.skipLogicParser("${For_how_many_years_have_you_be} != ''")).toEqual criteria: [
      name: "For_how_many_years_have_you_be"
      operator: "ans_notnull"
    ]

  it "matches untrimmed responses", ->
    expect(XLF.skipLogicParser("${what_for} = ' hello'")).toEqual criteria: [
      name: "what_for"
      operator: "resp_equals"
      response_value: " hello"
    ]

  it "doesn't parse compounded skip logic", () ->
    expect(() -> XLF.skipLogicParser('${q1} + ${q2} + ${q3} < 4')).toThrow new Error('criterion not recognized: "${q1} + ${q2} + ${q3} < 4"')

validation_logic_parser_tests = ->
  XLF = validationLogicParser: dkobo_xlform.model.utils.validationLogicParser
  it "parses multiple AND separated clauses", ->
    expect(XLF.validationLogicParser(". != 'value' AND . != ''")).toEqual
      criteria: [
        {
          name: "."
          operator: "resp_notequals"
          response_value: "value"
        }
        {
          name: "."
          operator: "ans_notnull"
        }
      ]
      operator: "AND"

  it "parses multiple OR separated clauses", ->
    expect(XLF.validationLogicParser(". != 'value' OR . != ''")).toEqual
      criteria: [
        {
          name: "."
          operator: "resp_notequals"
          response_value: "value"
        }
        {
          name: "."
          operator: "ans_notnull"
        }
      ]
      operator: "OR"