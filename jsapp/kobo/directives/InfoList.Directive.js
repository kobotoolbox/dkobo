/* exported InfoListDirective */
/* global staticFilesUri */
'use strict';

function InfoListDirective($rootScope, $restApi) {
    return {
        restrict: 'A',
        templateUrl: staticFilesUri + 'templates/InfoList.Template.html',
        scope: {
            items: '=',
            refreshItemList: '&',
            canAddNew: '@',
            name: '@',
            linkTo: '@',
            deleteItem: '&',
            canDelete: '@'
        },
        link: function (scope) {
            scope.kobocatLinkExists = function (item) {
                return window.koboConfigs && window.koboConfigs.kobocatServer;
            };


            scope.getHashLink = function (item) {
                var linkTo = scope.linkTo;
                return linkTo ? '/' + linkTo + '/' + item.id : '';
            };

            scope.getLink = function (item, format) {
                if(!format) {
                    format = "xml";
                }
                return scope.name.toLowerCase() + '/' + item.id + "?format=" + format;
            };

            scope.canDelete = scope.canDelete === 'true';
            $rootScope.canAddNew = scope.canAddNew === 'true';

            $rootScope.activeTab = scope.name;
        }
    };
}