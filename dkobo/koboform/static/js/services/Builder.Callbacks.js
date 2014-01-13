/* exported BuilderCallbacksService */
/* global surveyDraftApi */
/* global $routeTo */
/* global XLF */

'use strict';

function BuilderCallbacksService() {
    this.save = function () {
        return function () {
            if (this.validateSurvey()) {
                surveyDraftApi.save({
                        body: this.survey.toCSV(),
                        description: this.survey.get('description'),
                        title: this.survey.settings.get('form_title')
                    }, $routeTo.forms);
            }
        };
    };

    this.get = function (scope) {
        return function (response) {
            scope.xlfSurvey = XLF.createSurveyFromCsv(response.body);
            scope.xlfSurvey.__djangoModelDetails = response;
            //new SurveyApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
        };
    };
}