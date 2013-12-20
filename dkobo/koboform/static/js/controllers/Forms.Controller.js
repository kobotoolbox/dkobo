/* exported FormsController */
/* global _ */
'use strict';

function FormsController ($scope, $rootScope, $resource) {
    var formsApi = $resource('/survey_drafts/');

    $scope.infoListItems = formsApi.get();

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';
}