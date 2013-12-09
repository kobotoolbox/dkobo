function FormsController ($scope, $rootScope) {
    $scope.infoListItems = $scope.originalListItems = [
        {
            'title': 'Safety and Security',
            'info': 'Last modified yesterday at 5:03pm by Leroy Jenkins',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': 'Advanced',
            'tag2': ''
        },
        {
            'title': 'Educational Resources',
            'info': 'Last modified yesterday at 1:42pm by Rod Stewart',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': '',
            'tag2': ''
        },
        {
            'title': 'Food Supply Near Water Supply',
            'info': 'Last modified yesterday at 11:29am by Cat Stevens',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': 'Demographics',
            'tag2': 'Basic Questions'
        },
        {
            'title': 'Local Water Supply Survey',
            'info': 'Last modified yesterday at 8:50am by Katt Williams',
            'icon': 'fa-file-text-o',
            'iconBgColor': 'teal',
            'tag1': 'Demographics',
            'tag2': ''
        }
    ];

    $scope.filterList = function(criteria) {
        $scope.infoListItems = _.filter($scope.originalListItems, function (item) {
            item.title.indexOf(criteria) > -1 || item.info.indexOf(criteria) > -1;
        });
    }

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';
}