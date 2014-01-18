/*global XLF */
/*global describe */
/*global it */
/*global expect */
'use strict';

describe('XLF.skipLogicParser', function () {
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

    it('parses a single answered clause', function () {
        expect(XLF.skipLogicParser("${question_name}   !=   NULL")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_answered"
            }]
        });
    });

    it('parses a single not-answered clause', function () {
        expect(XLF.skipLogicParser("${question_name}   =   NULL")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_unanswered"
            }]
        });
    });

    it('parses multiple AND separated clauses', function () {
        expect(XLF.skipLogicParser("${question_name} != 'value' AND ${question_name} != NULL")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "resp_notequals",
                    response_value: "value"
                },

                {
                    name: "question_name",
                    operator: "resp_answered"
                }
            ],
            operator: 'AND'
        });
    });

    it('parses multiple OR separated clauses', function () {
        expect(XLF.skipLogicParser("${question_name} != 'value' OR ${question_name} != NULL")).toEqual({
            criteria: [
                {
                    name: "question_name",
                    operator: "resp_notequals",
                    response_value: "value"
                },

                {
                    name: "question_name",
                    operator: "resp_answered"
                }
            ],
            operator: 'OR'
        });
    });

    it('throws an error on multiple clauses with different join clauses', function () {
        expect(function() { XLF.skipLogicParser("${question_name} != 'value' OR ${question_name} != NULL AND ${question_name} != NULL ");}).toThrow();
    });

    it('parses a single multiselect clause', function () {
        expect(XLF.skipLogicParser("selected('question_name', 'value')")).toEqual({
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
        expect(XLF.skipLogicParser("selected('question_name', 'value') OR selected('question_name2', 'value2')")).toEqual({
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

    it('throws an error when the passed clause is invalid', function () {
        expect(function() { XLF.skipLogicParser("invalid clause");}).toThrow(new Error('criterion not recognized'));
    });
});