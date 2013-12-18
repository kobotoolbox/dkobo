/* exported BuilderDirective */
/* global SurveyTemplateApp */
'use strict';
function BuilderDirective($rootScope, $restApi, $routeTo) {
    return {
        link: function (scope, element) {
            /*jshint validthis: true */
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

            if (scope.routeParams.id){
                surveyDraftApi.get({id: scope.routeParams.id}, function builder_get_callback(response) {
                    scope.xlfSurvey = response;
                    renderBuilder();
                });
            } else {
                renderBuilder();
            }

            function renderBuilder() {
                new SurveyTemplateApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
            }
        }
    };
}
