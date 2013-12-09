function InfoListDirective($rootScope) {
    return {
        restrict: 'A',
        templateUrl: staticFilesUri + 'templates/InfoList.Template.html',
        scope: {
            items: '=',
            refreshItemList: '&',
            canAddNew: '@',
            name: '@'
        },
        link: function (scope, element, attributes) {
            scope.$watch('searchCriteria', function () {
                scope.refreshItemList(scope.searchCriteria);
            });

            scope.removeTags = function () {
                $( '.info-list-item__tag:empty' ).remove();
            };

            $rootScope.canAddNew = scope.canAddNew;
            $rootScope.activeTab = scope.name;
        }
    }
}