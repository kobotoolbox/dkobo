/* exported AssetEditorController */
/* global dkobo_xlform */
'use strict';
function AssetEditorController($scope, $rootScope, $routeParams, $routeTo, $api) {
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    var surveyDraftApi = $api.questions;
    $rootScope.activeTab = 'Question Library > Edit question';
    if($routeParams.id === 'new'){
        render_question(null)
    } else {
        surveyDraftApi.get({id: $routeParams.id}, function builder_get_callback(response) {
            render_question(response);
        });
    }

    function render_question(response) {
        if (response !== null) {
            $scope.xlfSurvey = dkobo_xlform.model.Survey.load(response.body);
            // temporarily saving response in __djangoModelDetails
            $scope.xlfSurvey.__djangoModelDetails = response;
        } else {
            $scope.xlfSurvey = null;
        }

        $scope.xlfQuestionApp = dkobo_xlform.view.QuestionApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
        $scope.xlfQuestionApp.render();
    }

    /*jshint validthis: true */
    function saveCallback() {
        if (this.validateSurvey()) {
            surveyDraftApi.save({
                    id: $routeParams.id === 'new' ? null : $routeParams.id,
                    tags: _.pluck($scope.tags.selected, 'label'),
                    body: this.survey.toCSV(),
                    description: this.survey.get('description'),
                    name: this.survey.settings.get('form_title'),
                    asset_type: 'question'
                }).then($routeTo.question_library);
        }
    }

    $scope.tags = {
            available: [],
            selected: []
        };

    $api.tags.list().then(function () {
        $scope.tags.available = $api.tags.items;
    });
}
