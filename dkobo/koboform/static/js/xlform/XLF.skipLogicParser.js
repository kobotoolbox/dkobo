/*global XLF*/
/*global _*/
'use strict';
XLF.skipLogicParser = (function () {
    var equalityCriterionPattern = /\${(\w+)}\s+(=|!=)\s+\'(\w+)\'/,
        existenceCriterionPattern = /\${(\w+)}\s+((?:=|!=)\s*(?:NULL|''))/i,
        criteriaJoinPattern = /and|or/gi;

    function parseCriterion(text) {
        var matches = text.match(equalityCriterionPattern);
        if (matches === null) {
            matches = text.match(existenceCriterionPattern);
        }

        if(!!matches) {
            matches[2] = matches[2].replace(/\s+/, '').replace(/null/i, 'NULL');
        } else {
            return parseMultiselectCriterion(text);
        }

        var equalityMapper = {
            '=': 'resp_equals',
            '!=': 'resp_notequals',
            "!=''": 'ans_notnull',
            "=''": 'ans_null'
        };

        var res = {
                name: matches[1],
                operator: equalityMapper[matches[2]],
            };

        if (matches[3]) {
            res.response_value = matches[3];
        }

        return res;
    }

    function parseMultiselectCriterion(text) {
        var matches = text.match(/selected\(\'(\w+)\',\s*\'(\w+)\'\)/);

        if (!matches) {
            throw new Error('criterion not recognized: "' + text + '"');
        }

        return {
            name: matches[1],
            operator: 'multiplechoice_selected',
            response_value: matches[2]
        };
    }

    return function (text) {
        var criteria = text.split(criteriaJoinPattern),
            criteriaLength = criteria.length,
            joinOperators = text.match(criteriaJoinPattern);

        if(!!joinOperators && _.uniq(joinOperators).length > 1) {
            throw new Error('multiple criteria join operators are not supported at the moment');
        }

        if (criteriaLength === 1) {
            return {
                criteria: [parseCriterion(text)]
            };
        } else {
            return {
                criteria: _.map(criteria, function (criterion) {
                    return parseCriterion(criterion);
                }),
                operator: joinOperators[0].toUpperCase()
            };
        }
    };
} ());