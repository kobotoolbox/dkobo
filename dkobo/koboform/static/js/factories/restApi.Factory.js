/* exported restApiFactory */
'use strict';
 
function restApiFactory($resource) {
    return {
        createSurveyDraftApi: function (id) {
            var customMethods = {};

            if (id) {
                customMethods = {
                    save: { method: 'PUT' }
                };
            }
            
            return $resource('/koboform/survey_draft/:id', { id: id || 0 }, customMethods);
        }
    };
}