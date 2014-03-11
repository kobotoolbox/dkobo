/*exported HeaderController*/
'use strict';

function HeaderController($scope, $rootScope, $miscUtils, $location) {

    $scope.pageIconColor = 'teal';
    $scope.pageTitle = 'Forms';
    $scope.pageIcon = 'fa-file-text-o';
    $rootScope.isLoading = false;

    $scope.topLevelMenuActive = '';
    $rootScope.activeTab = 'Forms';

    $scope.toggleTopMenu = function () {
        $rootScope.topLevelMenuActive = !!$rootScope.topLevelMenuActive ? '' : 'is-active';
    };

    $scope.$on('$locationChangeSuccess', function() {
        $rootScope.showCreateButton = $rootScope.showImportButton = !(""+$location.path()).match(/\/builder\/?(\d+|new)?$/);
    });

    $miscUtils.bootstrapFileUploader();
}