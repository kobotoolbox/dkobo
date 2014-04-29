/*global XLF */
/*global describe */
/*global it */
/*global expect */
'use strict';

describe('XLF.skipLogicParser', function () {
    // to get tests passing as they were, wrap the skipLogicParser in XLF object.
    var XLF = { skipLogicParser: dkobo_xlform.model.skipLogicParser };

    it('parses a single not-equals clause', function () {
        expect(XLF.skipLogicParser("${question_name}   !=   'value')")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_notequals",
                response_value: "value"
            }]
        });
    });

    it('parses a single equals clause', function () {
        expect(XLF.skipLogicParser("${question_name}   =   'value')")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_equals",
                response_value: "value"
            }]
        });
    });

    it('parses a decimal equals clause', function () {
        expect(XLF.skipLogicParser('${question_name} = 123.123')).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_equals",
                response_value: "123.123"
            }]
        })
    });

    it('parses a negative number equals clause', function () {
        expect(XLF.skipLogicParser('${question_name} = -1')).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_equals",
                response_value: "-1"
            }]
        })
    });

    it('parses a date equals clause', function () {
        expect(XLF.skipLogicParser("${question} = date('1234-12-12')")).toEqual({
            criteria: [{
                name: 'question',
                operator: 'resp_equals',
                response_value: "date('1234-12-12')"
            }]
        })
    });

    it('parses a single equals clause without padding between operands', function () {
        expect(XLF.skipLogicParser("${question_name}='value')")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_equals",
                response_value: "value"
            }]
        });
    });

    it('parses a single answered clause', function () {
        expect(XLF.skipLogicParser("${question_name}   !=   ''")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "ans_notnull"
            }]
        });
    });

    it('parses a single not-answered clause', function () {
        expect(XLF.skipLogicParser("${question_name}   =   ''")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "ans_null"
            }]
        });
    });

    it('parses multiple AND separated clauses', function () {
        expect(XLF.skipLogicParser("${question_name} != 'value' AND ${question_name} != ''")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "resp_notequals",
                    response_value: "value"
                },

                {
                    name: "question_name",
                    operator: "ans_notnull"
                }
            ],
            operator: 'AND'
        });
    });

    it('parses multiple OR separated clauses', function () {
        expect(XLF.skipLogicParser("${question_name} != 'value' OR ${question_name} != ''")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "resp_notequals",
                    response_value: "value"
                },

                {
                    name: "question_name",
                    operator: "ans_notnull"
                }
            ],
            operator: 'OR'
        });
    });

    it('throws an error on multiple clauses with different join clauses', function () {
        expect(function() { XLF.skipLogicParser("${question_name} != 'value' OR ${question_name} != NULL AND ${question_name} != NULL ");}).toThrow();
    });

    it('parses a single multiselect clause', function () {
        expect(XLF.skipLogicParser("selected(${question_name}, 'value')")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "multiplechoice_selected",
                    response_value: "value"
                }
            ]
        });
    });

    it('parses multiple multiselect clauses', function () {
        expect(XLF.skipLogicParser("selected(${question_name}, 'value') OR selected(${question_name2}, 'value2')")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "multiplechoice_selected",
                    response_value: "value"
                },
                {
                    name: "question_name2",
                    operator: "multiplechoice_selected",
                    response_value: "value2"
                }
            ],
            operator: "OR"
        });
    });

    it('parses a single negated multiselect clause', function () {
        expect(XLF.skipLogicParser("not(selected(${question_name}, 'value'))")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "multiplechoice_notselected",
                    response_value: "value"
                }
            ]
        });
    });

    it('parses multiple negated multiselect clauses', function () {
        expect(XLF.skipLogicParser("not(selected(${question_name}, 'value')) OR not(selected(${question_name2}, 'value2'))")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "multiplechoice_notselected",
                    response_value: "value",
                },
                {
                    name: "question_name2",
                    operator: "multiplechoice_notselected",
                    response_value: "value2"
                }
            ],
            operator: "OR"
        });
    });

    it('throws an error when the passed clause is invalid', function () {
        expect(function() { XLF.skipLogicParser("invalid clause");}).toThrow(new Error('criterion not recognized: "invalid clause"'));
    });

    it('doesn`t match and and or in names', function () {
        expect(XLF.skipLogicParser("${For_how_many_years_have_you_be} != ''")).toEqual({
            criteria: [{
                name: "For_how_many_years_have_you_be",
                operator: "ans_notnull"
            }]
        });
    });

    it('matches untrimmed responses', function () {
        expect(XLF.skipLogicParser("${what_for} = ' hello'")).toEqual({
            criteria: [{
                name: "what_for",
                operator: "resp_equals",
                response_value: " hello"
            }]
        });
    });
});