function BuilderController($scope, $rootScope) {
    $scope.startFromScratch = function() {
	    $scope.xlfSurvey = new XLF.Survey();
    }
    $rootScope.activeTab = 'Forms';
}
