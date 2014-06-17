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
            }
            scope.kobocatPublishForm = function (item) {
                function success (results, headers) {
                    // todo: friendly alert
                    alert('Survey Publishing succeeded');
                }
                function fail () {
                    // todo: friendly alert
                    alert('Survey Publishing failed');
                }
                $restApi.createSurveyDraftApi(item.id).publish({}, success, fail);
            }

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