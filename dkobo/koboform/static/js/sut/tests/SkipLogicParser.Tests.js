/*global XLF */
/*global describe */
/*global it */
/*global expect */
'use strict';

describe('XLF.skipLogicParser', function () {
    it('parses a single not equals clause', function () {
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
        expect(XLF.skipLogicParser("${question_name}   =   NULL")).toEqual({
            criteria: [{
                name: "question_name",
                operator: "resp_answered"
            }]
        });
    });
});