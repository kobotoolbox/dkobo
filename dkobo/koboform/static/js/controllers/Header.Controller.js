/*exported HeaderController*/
'use strict';

function HeaderController($scope, $rootScope) {
    $scope.pageIconColor = 'teal';
    $scope.pageTitle = 'Forms';
    $scope.pageIcon = 'fa-file-text-o';

    $scope.topLevelMenuActive = '';
    $rootScope.activeTab = 'Forms';

    $scope.toggleTopMenu = function () {
        $rootScope.topLevelMenuActive = !!$rootScope.topLevelMenuActive ? '' : 'is-active';
    };
}