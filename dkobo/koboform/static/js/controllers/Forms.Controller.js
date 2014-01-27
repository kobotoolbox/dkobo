/* exported FormsController */
/* global _ */
'use strict';

function FormsController ($scope, $rootScope, $resource, $miscUtils) {
    var formsApi = $resource('api/survey_drafts/:id', {id: '@id'});

    $scope.infoListItems = formsApi.query();

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';

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

    $rootScope.$watch('updateFormList', function () {
        if ($rootScope.updateFormList) {
            $scope.infoListItems = formsApi.query();
            $rootScope.updateFormList = false;
        }
    });
}