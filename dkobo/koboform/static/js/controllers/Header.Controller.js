/*exported HeaderController*/
'use strict';

function HeaderController($scope, $rootScope, $miscUtils) {
    $scope.pageIconColor = 'teal';
    $scope.pageTitle = 'Forms';
    $scope.pageIcon = 'fa-file-text-o';
    $rootScope.isLoading = false;

    $scope.topLevelMenuActive = '';
    $rootScope.activeTab = 'Forms';

    $scope.toggleTopMenu = function () {
        $rootScope.topLevelMenuActive = !!$rootScope.topLevelMenuActive ? '' : 'is-active';
    };

    $miscUtils.bootstrapFileUploader($rootScope);
}