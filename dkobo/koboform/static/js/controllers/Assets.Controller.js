function AssetsController($scope, $rootScope, $resource) {
  var assets = $resource('/question_library_forms/');

  assets.get(function (result) {
    $scope.infoListItems = $scope.originalListItems = result.list;
  });
  $scope.filterList = function(criteria) {
    $scope.infoListItems = _.filter($scope.originalListItems, function (item) {
      item.title.indexOf(criteria) > -1 || item.info.indexOf(criteria) > -1;
    });
  }

  $scope.removeTags = function () {
    $( '.info-list-item__tag:empty' ).remove();
  }

  $rootScope.canAddNew = true;
  $rootScope.activeTab = 'Assets';
}