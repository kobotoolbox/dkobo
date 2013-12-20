/* exported InfoListDirective */
/* global staticFilesUri */
'use strict';

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
        link: function (scope) {
            scope.$watch('searchCriteria', function () {
                scope.refreshItemList(scope.searchCriteria);
            });

            scope.getHashLink = function (item) {
                var linkTo = scope.linkTo;
                return linkTo ? '/' + linkTo + '/' + item.id : '';
            };

            $rootScope.canAddNew = scope.canAddNew === 'true' ? true : false;
            $rootScope.activeTab = scope.name;
        }
    };
}