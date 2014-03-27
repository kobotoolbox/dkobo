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

            return $resource('/api/survey_drafts/:id', { id: id || 0 }, customMethods);
        },
        create_question_api: function () {
            return $resource('/api/library_assets');
        }
    };
}