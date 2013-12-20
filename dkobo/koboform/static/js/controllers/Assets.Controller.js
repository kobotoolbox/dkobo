/*exported AssetsController*/
'use strict';
function AssetsController($scope, $rootScope, $resource) {
    var assets = $resource('/question_library_forms/');

    $scope.infoListItems = assets.query();

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Assets';
}