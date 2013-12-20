function InfoListDirective($rootScope) {
    return {
        restrict: 'A',
        templateUrl: staticFilesUri + 'templates/InfoList.Template.html',
        scope: {
            items: '=',
            refreshItemList: '&',
            canAddNew: '@',
            name: '@',
            linkTo: '@'
        },
        link: function (scope, element, attributes) {
            scope.$watch('searchCriteria', function () {
                scope.refreshItemList(scope.searchCriteria);
            });

            scope.getHashLink = function (item) {
                var linkTo = scope.linkTo;
                return linkTo ? '/' + linkTo + '/' + item.id : '';
            }

            scope.getLink = function (item) {
                return scope.name.toLowerCase() + '/' + item.id;
            }

            $rootScope.canAddNew = scope.canAddNew;
            $rootScope.activeTab = scope.name;
        }
    }
}