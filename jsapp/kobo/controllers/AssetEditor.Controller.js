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
                    id: $routeParams.id,
                    body: this.survey.toCSV(),
                    description: this.survey.get('description'),
                    name: this.survey.settings.get('form_title'),
                    asset_type: 'question'
                }, $routeTo.question_library);
        }
    }

    $scope.tags = {
        available: [
            {id: -1, name: 'Demographics' },
            {id: -1, name: 'Priorities services' },
            {id: -1, name: 'Security' },
            {id: -1, name: 'Disputes' },
            {id: -1, name: 'Domestic Violence' },
            {id: -1, name: 'Mortality' },
            {id: -1, name: 'Exposure to War Violence' },
            {id: -1, name: 'Former combatants' },
            {id: -1, name: 'Victims' },
            {id: -1, name: 'Measures for Victims' },
            {id: -1, name: 'Monuments' },
            {id: -1, name: 'Origins of conflicts' },
            {id: -1, name: 'Truth' },
            {id: -1, name: 'Information' },
            {id: -1, name: 'Accountability' },
            {id: -1, name: 'Justice' },
            {id: -1, name: 'International Criminal Court' },
            {id: -1, name: 'Peace' },
            {id: -1, name: 'Group membership' }
        ],
        selected: []
    };

    for (var i = 0; i < 3; i++) {
        $scope.tags.selected[i] = $scope.tags.available[i];
    }
}
