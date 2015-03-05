/* exported FormsController */
/* global _ */
'use strict';

kobo.controller('FormsController', ['$scope', '$rootScope', '$resource', '$miscUtils', '$api', FormsController]);
function FormsController ($scope, $rootScope, $resource, $miscUtils, $api) {
    var formsApi = $resource('api/survey_drafts/:id', {id: '@id'});
    $scope.items_loaded = false;
    $rootScope.add_form = '+ Add Form';

    var load_forms = function () {
        formsApi.query(function (items) {
            var currentItem, i, rc;

            for (i = 0; i < items.length; i++) {
                currentItem = items[i];

                // populate "100 questions" string
                if (currentItem.summary && !(''+currentItem !== '[Object object]') && 'rowCount' in currentItem.summary) {
                    rc = currentItem.summary.rowCount;
                    currentItem.rowCount = '' + rc + ' question' + (rc===1 ? '' : 's');
                }

                currentItem.date_modified = new Date(currentItem.date_modified);
            }

            $scope.infoListItems = items;
            $scope.items_loaded = true;
        });
    };

    load_forms();

    $miscUtils.bootstrapSurveyUploader(function (response) {
            $location.path('/builder/' + response.survey_draft_id);
        },
        '-emptyformlist');

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';
    $rootScope.icon_link = 'forms';

    $scope.deleteSurvey = function (survey) {
        var id = survey.id;
        if($miscUtils.confirm('Are you sure you want to delete this survey? The operation is not undoable.')) {
            survey.$delete({id: survey.id}, function () {
                $scope.infoListItems = _.filter($scope.infoListItems,
                    function (item) {
                        return item.id !== id;
                    }
                );
            });
        }
    };

    $miscUtils.changeFileUploaderSuccess(load_forms);

    $scope.$watch('infoListItems', function () {
        if ($scope.infoListItems) {
            $scope.additionalClasses = $scope.infoListItems.length === 0 ? 'content--centered' : '';
            $rootScope.showCreateButton = $scope.infoListItems.length > 0
        }
    }, true);

    $scope.clone_survey = function (survey) {
        var surveyDraftApi = $api.surveys;
        if (!survey.body) {
            throw new Error("Cannot clone survey right now.");
        }
        surveyDraftApi.save({
            body: survey.body,
            description: survey.description,
            name: survey.name
        }).then(function() {
            load_forms()
        }, function(response) {
            $miscUtils.alert('a server error occurred: \n' + response.statusText, 'Error');
        });
    }
}