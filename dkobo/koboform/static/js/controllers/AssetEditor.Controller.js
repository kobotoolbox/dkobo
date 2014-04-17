/* exported AssetEditorController */
/* global XLF */
/* global SurveyApp */
'use strict';
function AssetEditorController($scope, $rootScope, $routeParams, $restApi, $routeTo) {
    var surveyDraftApi = $restApi.create_question_api($scope, $routeParams.id);
    $rootScope.activeTab = 'Question Library > Edit question';
    surveyDraftApi.get({id: $routeParams.id}, function builder_get_callback(response) {
        $scope.xlfSurvey = XLF.createSurveyFromCsv(response.body);
        // temporarily saving response in __djangoModelDetails
        $scope.xlfSurvey.__djangoModelDetails = response;
        $scope.xlfQuestionApp = QuestionApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
        $scope.xlfQuestionApp.render();
    });

    /*jshint validthis: true */
    function saveCallback() {
        if (this.validateSurvey()) {
            surveyDraftApi.save({
                    body: this.survey.toCSV(),
                    description: this.survey.get('description'),
                    name: this.survey.settings.get('form_title'),
                    asset_type: 'question'
                }, $routeTo.question_library);
        }
    }
}