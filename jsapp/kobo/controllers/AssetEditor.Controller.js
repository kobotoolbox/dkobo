/* exported AssetEditorController */
/* global dkobo_xlform */
'use strict';
function AssetEditorController($scope, $rootScope, $routeParams, $restApi, $routeTo) {
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    var surveyDraftApi = $restApi.create_question_api($scope, $routeParams.id);
    $rootScope.activeTab = 'Question Library > Edit question';
    surveyDraftApi.get({id: $routeParams.id}, function builder_get_callback(response) {
        $scope.xlfSurvey = dkobo_xlform.model.Survey.load(response.body);
        // temporarily saving response in __djangoModelDetails
        $scope.xlfSurvey.__djangoModelDetails = response;
        $scope.xlfQuestionApp = dkobo_xlform.view.QuestionApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
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
