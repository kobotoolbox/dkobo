/* exported BuilderCallbacksService */
/* global surveyDraftApi */
/* global $routeTo */
/* global dkobo_xlform */

'use strict';

function BuilderCallbacksService() {
    this.save = function () {
        return function () {
            if (this.validateSurvey()) {
                surveyDraftApi.save({
                        body: this.survey.toCSV(),
                        description: this.survey.get('description'),
                        title: this.survey.settings.get('form_title')
                    }).then($routeTo.forms);
            }
        };
    };

    this.get = function (scope) {
        return function (response) {
            scope.xlfSurvey = dkobo_xlform.model.Survey.load(response.body);
            scope.xlfSurvey.__djangoModelDetails = response;
            //new dkobo_xlform.view.SurveyApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
        };
    };
}