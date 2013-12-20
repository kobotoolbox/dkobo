function AssetsController($scope, $rootScope, $resource) {
  var assets = $resource('/question_library_forms/');

  $scope.infoListItems = assets.get();
  
  $rootScope.canAddNew = true;
  $rootScope.activeTab = 'Assets';
}