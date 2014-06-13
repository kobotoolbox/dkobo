/* exported FormsController */
/* global _ */
'use strict';

function FormsController ($scope, $rootScope, $resource, $miscUtils) {
    var formsApi = $resource('api/survey_drafts/:id', {id: '@id'});
    $scope.items_loaded = false;

    var load_forms = function () {
        formsApi.query(function (items) {
            var currentItem, i, rc;

            for (i = 0; i < items.length; i++) {
                currentItem = items[i];

                // populate "100 questions" string
                if (currentItem.summary && !(''+currentItem !== '[Object object]') && 'rowCount' in currentItem.summary) {
                    rc = currentItem.summary.rowCount;
                    currentItem.rowCount = '' + rc + ' question' + (rc===1 ? '' : 's');
                }

                currentItem.date_modified = new Date(currentItem.date_modified);
            }

            $scope.infoListItems = items;
            $scope.items_loaded = true;
        });
    };

    load_forms();

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';
    $rootScope.icon_link = 'forms';

    $scope.deleteSurvey = function (survey) {
        var id = survey.id;
        if($miscUtils.confirm('Are you sure you want to delete this survey? The operation is not undoable.')) {
            survey.$delete({id: survey.id}, function () {
                $scope.infoListItems = _.filter($scope.infoListItems,
                    function (item) {
                        return item.id !== id;
                    }
                );
            });
        }
    };

    $miscUtils.changeFileUploaderSuccess(load_forms);

    $scope.$watch('infoListItems', function () {
        if ($scope.infoListItems) {
            $scope.additionalClasses = $scope.infoListItems.length === 0 ? 'content--centered' : '';
            $rootScope.showCreateButton = $scope.infoListItems.length > 0
        }
    }, true);
}