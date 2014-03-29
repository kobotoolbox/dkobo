/*exported BuilderController*/
'use strict';

function BuilderController($scope, $rootScope, $routeParams, $miscUtils, $location) {
    $rootScope.activeTab = 'Forms';
    $scope.routeParams = $routeParams;
    $rootScope.deregisterLocationChangeStart = $rootScope.$on('$locationChangeStart', handleUnload);
    function handleUnload(event) {
        if ($miscUtils.confirm('Are you sure you want to leave? you will lose any unsaved changes.')){
            $rootScope.deregisterLocationChangeStart();
            $(window).unbind('beforeunload');
        } else {
            $miscUtils.preventDefault(event);
        }
    }
    $(window).bind('beforeunload', function(){
        return 'Are you sure you want to leave?';
    });

    $scope.add_item = function (item) {
        //add item.backbone_model contains the survey representing the question
    }
}
