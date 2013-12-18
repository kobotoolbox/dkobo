/* exported FormsController */
/* global _ */
'use strict';

function FormsController ($scope, $rootScope, $resource) {
    var formsApi = $resource('/survey_drafts/');

    formsApi.get(function (result) {
        $scope.infoListItems = $scope.originalListItems = result.list;
    });

    $scope.filterList = function(criteria) {
        $scope.infoListItems = _.filter($scope.originalListItems, function (item) {
            return item.title.indexOf(criteria) > -1 || item.info.indexOf(criteria) > -1;
        });
    };

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';
}