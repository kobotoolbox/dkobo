/* exported InfoListDirective */
/* global staticFilesUri */
'use strict';

function InfoListDirective($rootScope, $restApi, $miscUtils, $location) {
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


            $miscUtils.bootstrapSurveyUploader(function (response) {
                $location.path('/builder/' + response.survey_draft_id);
            });

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

            scope.toggleAddFormDropdown = function () {
                scope.showAddFormDropdown = scope.isShowAddFormDropdownShowing = !scope.showAddFormDropdown
            };

            scope.hideAddFormDropdown = function () {
                scope.showAddFormDropdown = false;
                scope.$apply();
            };

            scope.hideDownloadFormDropdown = function (item) {
                item.showDownloadDropdown = false;
                scope.$apply();
            };

            scope.toggleDownloadFormDropdown = function (item) {
                item.showDownloadDropdown = item.isShowing = !item.showDownloadDropdown
            };

            scope.canDelete = scope.canDelete === 'true';
            $rootScope.canAddNew = scope.canAddNew === 'true';

            $rootScope.activeTab = scope.name;
        }
    };
}