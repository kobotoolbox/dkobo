/* exported restApiFactory */
'use strict';

function restApiFactory($resource) {
    return {
        createSurveyDraftApi: function (id) {
            var customMethods = {};
            id = id === 'new' ? null : id;
            if (id) {
                customMethods = {
                    save: { method: 'PUT' }
                };
            }

            return $resource('/koboform/survey_draft/:id', { id: id || 0 }, customMethods);
        },
        create_question_api: function () {
            var info_list_items = [
                { label: 'Currently, what is your main priority or concern?', type: 'Select Many'},
                { label: 'If you have a dispute in your community, to whom do you take it first?', type: 'Select Many' },
                { label: 'Why do you take it first to that person or institution?', type: 'Select Many' },
                {
                    label: 'If needed, what kind of documentation do you have prove your access or interest to this land? (READ RESPONSES)',
                    type: 'Select Many',
                    responses: ['Title deed', 'Tribal certificate', 'Rental Agreement (lease)', 'Letter or document']
                },
                { label: 'What type of crops does your household sell, if any?', type: 'Select Many' },
                { label: 'During the war, did someone take over all or part of your house plot?', type: 'Select Many' },
                { label: 'During the war, did someone take over all or part of your household farm land?', type: 'Select Many' },
                { label: 'Since the end of the war in 2003, did someone take over all or part of your house plot?', type: 'Select Many' },
                { label: 'What what describe your access to this land? (READ RESPONSES)', type: 'Select Many' },
            ];

            return {
                query: function (fn) {
                    return fn(info_list_items);
                }
            }
        }
    };
}