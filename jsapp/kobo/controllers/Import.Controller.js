/*exported ImportController*/
'use strict';

function ImportController($scope, $rootScope, $cookies) {
    $rootScope.canAddNew = false;
    $rootScope.activeTab = 'Import CSV';
    $scope.csrfToken = $cookies.csrftoken;
}