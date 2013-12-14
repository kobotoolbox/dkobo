/* exported BuilderDirective */
/* global SurveyTemplateApp */
'use strict';
function BuilderDirective($rootScope, $restApi, $routeTo) {
    return {
        link: function (scope, element) {
            var surveyDraftApi = $restApi.createSurveyDraftApi();

            function saveCallback() {
                if (this.validateSurvey()) {
                    surveyDraftApi.save({
                            body: this.survey.toCSV(),
                            description: this.survey.get('description'),
                            title: this.survey.settings.get('form_title')
                        }, $routeTo.forms);
                }
            }
            new SurveyTemplateApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
        }
    };
}
