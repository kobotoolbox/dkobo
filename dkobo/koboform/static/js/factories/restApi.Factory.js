/* exported restApiFactory */
'use strict';

function restApiFactory($resource) {
    return {
        createSurveyDraftApi: function (id) {
            var customMethods = {};
            id = id === 'new' ? null : id;
            if (id === null) {
                return $resource('/api/survey_drafts', {}, {
                    save: { method: 'POST' }
                });
            } else {
                return $resource('/api/survey_drafts/:id', { id: id }, {
                    save: { method: 'PATCH' }
                });
            }

        },
        create_question_api: function () {
            return $resource('/api/library_assets');
        }
    };
}