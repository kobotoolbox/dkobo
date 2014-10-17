/* exported AssetsController */
/* global dkobo_xlform */
/* global _ */
'use strict';
function AssetsController($scope, $rootScope, $filter, $miscUtils, $api) {
    $scope.sort_criteria = '-date_modified';
    $scope.tagsSortCriteria = '-date_modified';
    $scope.tagFilters = {};
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    $scope.filters = {};
    $rootScope.icon_link = 'library/questions';

    $scope.lists = {
        tags: {},
        questions: {}
    };

    $miscUtils.bootstrapQuestionUploader($api.questions.list);

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
                $api.questions.remove({id: item.id});
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

    $scope.toggleTagInFilters = function (items) {
        var tags = _.filter(items, function (item) {
            return item.meta.isSelected;
        });

        $scope.filters.tags = _.pluck(tags, 'label');
        if ($scope.filters.tags.length === 0) {
            delete $scope.filters.tags;
        }
    };

    $scope.cancelAdd = function () {
        delete $scope.newTagName;
        $scope.isAdding = false;
    };
    $scope.addNewTag__KeyDown = function ($event) {
        if ($event.which === 13) {
            $scope.addNewTag();
        } else if ($event.which === 27) {
            $scope.cancelAdd()
        }
    };

    $scope.addNewTag = function () {
        var api = $restApi.createTagsApi();
        if(!$scope.newTagName) {
            return;
        }
        api.save({label: $scope.newTagName});
        delete $scope.newTagName;
        $scope.isAdding = false;
    };

    $scope.enableAdd = function () {
        $scope.isAdding = true;
        $scope.$broadcast('showAddBox');
    };
}
