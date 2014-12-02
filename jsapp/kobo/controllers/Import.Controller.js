/*exported ImportController*/
'use strict';

kobo.controller('ImportController', ['$scope', '$rootScope', '$cookies', ImportController]);
function ImportController($scope, $rootScope, $cookies) {
    $rootScope.canAddNew = false;
    $rootScope.activeTab = 'Import CSV';
    $scope.csrfToken = $cookies.csrftoken;
}