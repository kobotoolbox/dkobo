/* exported AssetsController */
/* global dkobo_xlform */
/* global _ */
'use strict';
function AssetsController($scope, $rootScope, $resource, $restApi, $timeout, $filter, $miscUtils) {
    var assets = $restApi.createQuestionApi($scope);
    $scope.sort_criteria = '-date_modified';
    $scope.tagsSortCriteria = '-date_modified';
    $scope.tagFilters = {};
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    $scope.filters = {};
    $rootScope.icon_link = 'library/questions';

    assets.list();

    $miscUtils.bootstrapQuestionUploader(assets.list);

    $scope.select_all = null;

    function select_all() {
        var new_class = $scope.select_all ? 'questions__question--selected' : '';
        var filter = $filter('filter');

        if (!$scope.is_updating_select_all) {
            _.each($scope.info_list_items, function (item) {
                item.meta.is_selected = false;
                item.meta.additionalClasses = '';
            });

            _.each(filter($scope.info_list_items, $scope.filters), function (item) {
                item.meta.is_selected = $scope.select_all;
                item.meta.additionalClasses = new_class;
            });
        }

        $scope.is_updating_select_all = false;
    }

    $scope.delete_selected = function () {
        if (!$miscUtils.confirm('are you sure you want to delete ' + $scope.get_selected_amount() + '?')) {
            return;
        }
        _.each($scope.info_list_items, function (item) {
            if (item.meta.is_selected) {
                assets.remove({id: item.id});
            }
        });

        $scope.info_list_items = _.filter($scope.info_list_items, function (item) {
            return !item.meta.is_selected
        });
    };

    $scope.$watch('filters.label', function () {
        select_all();
    });

    $scope.$watch('select_all', function () {
        if ($scope.select_all === null) {
            return;
        }
        select_all();
    });

    $scope.$watch('show_responses', function () {
        if (typeof $scope.show_responses === 'undefined') {
            return;
        }

        _.each($scope.info_list_items, function (item) {
            $miscUtils.toggle_response_list(item);
        });
    });

    $scope.get_selected_count = function () {
        return _.filter($scope.info_list_items, function (item) {
            return item.meta ? item.meta.is_selected : false;
        }).length;
    };

    $scope.get_selected_amount = function () {
        var amount = $scope.get_selected_count();

        if (amount > 1 || amount === 0) {
            return amount + ' questions';
        } else {
            return amount + ' question';
        }
    };

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Question Library';

    $scope.toggleTagInFilters = function (item) {
        if (!$scope.filters.tags) {
            $scope.filters.tags = [];
        }
        var tags = $scope.filters.tags;

        if (item.meta.isSelected) {
            tags.push({id: item.id});
        } else {
            tags.splice(_.indexOf(tags, _.filter(tags, function (tag) { return tag.id === item.id })[0]), 1);
        }

        if (tags.length === 0) {
            delete $scope.filters.tags;
        }
    };
}
