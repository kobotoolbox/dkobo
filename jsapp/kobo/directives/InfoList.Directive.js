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
            scope.kobocatFormPublished = function (item) {
                var serverExists = window.koboConfigs && window.koboConfigs.kobocatServer;
                // check to see if item already has an xform_id
                return !!item.kobocat_published_form_id;
            }
            scope.getKobocatUrl = function (item) {
                return "/survey_drafts/" + item.id + "/published?redirect=true";
            }
            scope.kobocatPublishForm = function (item) {
                function success (results, headers) {
                    var kcUrl = results.kobocat_published_form_url || item.kobocat_published_form_url;
                    window.location = kcUrl;
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