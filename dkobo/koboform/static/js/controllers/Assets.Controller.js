function AssetsController($scope, $rootScope) {
  $scope.infoListItems = $scope.originalListItems = [
    {
      'title': 'Where do you get water?',
      'info': 'Last modified yesterday at 5:03pm by Leroy Jenkins',
      'icon': 'fa-question',
      'iconBgColor': 'purple',
      'tag1': 'Demographics',
      'tag2': 'Basic Questions'
    },
    {
      'title': 'Nick\'s Question Block',
      'info': 'Last modified yesterday at 1:42pm by Rod Stewart',
      'icon': 'fa-th-large',
      'iconBgColor': 'dark-blue',
      'tag1': 'Advanced',
      'tag2': ''
    },
    {
      'title': 'Rating Scale 1-5',
      'info': 'Last modified yesterday at 11:29am by Cat Stevens',
      'icon': 'fa-list-ul',
      'iconBgColor': 'brown',
      'tag1': '',
      'tag2': ''
    },
    {
      'title': 'Local Water Supply Survey',
      'info': 'Last modified yesterday at 8:50am by Katt Williams',
      'icon': 'fa-file-o',
      'iconBgColor': 'green',
      'tag1': 'Demographics',
      'tag2': 'Advanced'
    },
    {
      'title': 'Weather Rating Scale 1-3',
      'info': 'Last modified yesterday at 11:29am by Kendrick Lamar',
      'icon': 'fa-list-ul',
      'iconBgColor': 'brown',
      'tag1': 'Basic Questions',
      'tag2': ''
    }
  ];

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