/* exported FormsController */
'use strict';

function FormsController ($scope, $rootScope, $resource) {
    var formsApi = $resource('api/survey_drafts');

    $scope.infoListItems = formsApi.query();

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';
}