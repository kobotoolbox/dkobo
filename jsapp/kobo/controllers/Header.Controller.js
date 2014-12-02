/*exported HeaderController*/
'use strict';

kobo.controller('HeaderController', ['$scope', '$rootScope', '$location', HeaderController]);
function HeaderController($scope, $rootScope, $location) {

    $scope.pageIconColor = 'teal';
    $scope.pageTitle = 'Forms';
    $scope.pageIcon = 'fa-file-text-o';
    $rootScope.isLoading = false;

    $rootScope.topLevelMenuActive = '';
    $rootScope.activeTab = 'Forms';

    $scope.toggleTopMenu = function ($event) {
        if (!!$event) {
            $event.stopPropagation();
        }
        $rootScope.topLevelMenuActive = !!$rootScope.topLevelMenuActive ? '' : 'is-active';
    };

    $rootScope.closeTopMenu = function () {
        $rootScope.topLevelMenuActive = '';
    };

    $scope.$on('$locationChangeSuccess', function() {
        $rootScope.showCreateButton = $rootScope.showImportButton = !(""+$location.path()).match(/\/builder\/?(\d+|new)?$/);
    });
    $scope.toggleBleedingEdge = function ($event) {
        if ($event.shiftKey) {
            $('body').toggleClass('bleeding-edge');
        }
    };
}