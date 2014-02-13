/* exported FormsController */
/* global _ */
'use strict';

function FormsController ($scope, $rootScope, $resource, $miscUtils) {
    var formsApi = $resource('api/survey_drafts/:id', {id: '@id'});

    $scope.infoListItems = formsApi.query(function (items) {
        for (var i = 0; i < items.length; i++) {
            var currentItem = items[i];
            currentItem.date_modified = new Date(currentItem.date_modified);
        }
    });

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

    $scope.$watch('infoListItems', function () {
        $scope.additionalClasses = $scope.infoListItems.length === 0 ? 'content--centered' : '';
    }, true);

    $rootScope.updateFormList = function () {
        if ($rootScope.updateFormList) {
            formsApi.query(function (items) {
                for (var i = 0; i < items.length; i++) {
                    var currentItem = items[i];
                    currentItem.date_modified = new Date(currentItem.date_modified);
                }

                $scope.infoListItems = items;
            });
        }
    };
}