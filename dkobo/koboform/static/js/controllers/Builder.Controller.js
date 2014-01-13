/*exported BuilderController*/
'use strict';

function BuilderController($scope, $rootScope, $routeParams, $miscUtils) {
    $rootScope.activeTab = 'Forms';
    $scope.routeParams = $routeParams;
    $rootScope.deregisterLocationChangeStart = $rootScope.$on('$locationChangeStart', handleUnload);
    function handleUnload(event) {
        if ($miscUtils.confirm('Are you sure you want to leave? you will loose any unsaved changes.')){
            $rootScope.deregisterLocationChangeStart();
        } else {
            $miscUtils.preventDefault(event);
        }
    }
    $(window).bind('beforeunload', function(){
        return 'Are you sure you want to leave?';
    });
}
