/*global XLF*/
'use strict';
XLF.skipLogicParser = function (text) {
    var matches = text.match(/\${(\w+)}\s+(?:(=|!=)\s+\'(\w+)\'|(=\s*null))/i);
    var equalityMapper = {
        '=': 'resp_equals',
        '!=': 'resp_notequals'
    };

    matches[2] = matches[2].replace(/\s+/, '');

    res = {
        criteria: [{
            name: matches[1],
            operator: equalityMapper[matches[2]],
        }]
    };

    if (matches[3]) {
        res.criteria[0].response_value= matches[3];
    }

    return res
};