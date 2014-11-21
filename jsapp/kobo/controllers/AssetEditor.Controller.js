/* exported AssetEditorController */
/* global dkobo_xlform */
'use strict';
kobo.controller('AssetEditorController', ['$scope', '$rootScope', '$routeParams', '$routeTo', '$api', '$q', AssetEditorController]);

function AssetEditorController($scope, $rootScope, $routeParams, $routeTo, $api, $q) {
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    var surveyDraftApi = $api.questions;
    $rootScope.activeTab = 'Question Library > Edit question';
    if($routeParams.id === 'new'){
        render_question(null);
        listTags();
    } else {
        surveyDraftApi.get({id: $routeParams.id}).then(render_question);
    }
    var selectedTags = null;
    function render_question(response) {
        if (response !== null) {
            $scope.questionId = response.id;
            $scope.xlfSurvey = dkobo_xlform.model.Survey.load(response.body);
            // temporarily saving response in __djangoModelDetails
            $scope.xlfSurvey.__djangoModelDetails = response;
            selectedTags = response.tags;
        } else {
            $scope.xlfSurvey = null;
        }

        $scope.xlfQuestionApp = dkobo_xlform.view.QuestionApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
        $scope.xlfQuestionApp.render();
        listTags();
    }

    /*jshint validthis: true */
    function saveCallback() {
        if (this.validateSurvey()) {
            return surveyDraftApi.save({
                    id: $scope.questionId,
                    body: this.survey.toCSV(),
                    description: this.survey.get('description'),
                    tags: $scope.tags.selected.length ? $scope.tags.selected.split(',') : '',
                    name: this.survey.settings.get('form_title'),
                    asset_type: 'question'
                }).then($routeTo.question_library);
        }
        var deferred = $q.defer();
        deferred.resolve();
        return deferred.promise;
    }

    $scope.tags = {
            available: [],
            selected: ''
        };

    function listTags() {
        $api.tags.list().then(function () {
            $scope.tags.available = _.pluck($api.tags.items, 'label');
            if (selectedTags !== null) {
                $scope.tags.selected = _.pluck(_.filter($api.tags.items, function (tag) {
                    return selectedTags.indexOf(tag.label) > -1;
                }), 'label').join(',');
            }
        });
    }
}
