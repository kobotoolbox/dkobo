/* exported restApiFactory */
'use strict';
 
function restApiFactory($resource) {
    return {
        createSurveyDraftApi: function () {
            return $resource('/koboform/survey_draft/');
        }
    };
}