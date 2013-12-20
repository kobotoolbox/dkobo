/* exported BuilderDirective */
/* global SurveyTemplateApp */
/* global SurveyApp */
/* global XLF */
'use strict';

function BuilderDirective($rootScope, $restApi, $routeTo) {
    return {
        link: function (scope, element) {
            /*jshint validthis: true */
            var surveyDraftApi = $restApi.createSurveyDraftApi(scope.routeParams.id);

            function saveCallback() {
                if (this.validateSurvey()) {
                    surveyDraftApi.save({
                            body: this.survey.toCSV(),
                            description: this.survey.get('description'),
                            title: this.survey.settings.get('form_title')
                        }, $routeTo.forms);
                }
            }

            if (scope.routeParams.id){
                surveyDraftApi.get({id: scope.routeParams.id}, function builder_get_callback(response) {
                    scope.xlfSurvey = XLF.createSurveyFromCsv(response.body);
                    // temporarily saving response in __djangoModelDetails
                    scope.xlfSurvey.__djangoModelDetails = response;
                    new SurveyApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
                });
            } else {
                new SurveyTemplateApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
            }
        }
    };
}
