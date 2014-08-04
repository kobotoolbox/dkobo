/* exported AssetsController */
/* global dkobo_xlform */
/* global _ */
'use strict';
function AssetsController($scope, $rootScope, $resource, $restApi, $timeout, $filter, $miscUtils) {
    var assets = $restApi.create_question_api($scope);
    $scope.sort_criteria = '-date_modified';
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    $scope.filters = {};
    $rootScope.icon_link = 'library/questions';

    assets.list();

    $scope.toggle_selected = function (item, $event) {
        var i,
            currently_selected = item.meta.is_selected,
            more_than_one_selected = false,
            current,
            select_question,
            select_all = true;

        if (!$event.ctrlKey) {
            for (i = 0; i < $scope.info_list_items.length; i++) {
                current = $scope.info_list_items[i];
                if (current != item) {
                    more_than_one_selected = more_than_one_selected || (currently_selected && current.meta.is_selected);
                }
                current.meta.question_class = 'questions__question';
                current.meta.is_selected = false;
            }
        }

        select_question = more_than_one_selected || !currently_selected;
        item.meta.is_selected = select_question
        item.meta.question_class = select_question ? 'questions__question questions__question--selected' : 'questions__question';

        for (i = 0; i < $scope.info_list_items.length; i++) {
            select_all = select_all && $scope.info_list_items[i].meta.is_selected;
        }

        $scope.is_updating_select_all = true;
        if ($scope.select_all === select_all) {
            $scope.is_updating_select_all = false;
        } else {
            $scope.select_all = select_all
        }

    };

    $scope.toggle_response_list = function (item) {
        if (item.type !== 'select_one' && item.type !== 'select_all' && item.type !== 'select_multiple') {
            return;
        }

        if (item.meta.show_responses) {
            item.meta.show_responses = false;
            item.meta.question_type_class = 'question__type';
            item.meta.question_type_icon = 'fa fa-caret-right';
            item.meta.question_type_icon_class = 'question__type-icon';
        } else {
            item.meta.question_type_class = 'question__type question__type--expanded';
            item.meta.question_type_icon_class = 'question__type-icon question__type--expanded-icon';
            item.meta.question_type_icon = 'fa fa-caret-down';
            item.meta.show_responses = true;
        }
    };

    $scope.select_all = null;

    function select_all() {
        var new_class = $scope.select_all ? 'questions__question questions__question--selected' : 'questions__question';
        var filter = $filter('filter');

        if (!$scope.is_updating_select_all) {
            _.each($scope.info_list_items, function (item) {
                item.meta.is_selected = false;
                item.meta.question_class = 'questions__question';
            });

            _.each(filter($scope.info_list_items, $scope.filters), function (item) {
                item.meta.is_selected = $scope.select_all;
                item.meta.question_class = new_class;
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
            return;e
        }

        _.each($scope.info_list_items, function (item) {
            $scope.toggle_response_list(item);
        });
    });

    $scope.get_selected_count = function () {
        return _.filter($scope.info_list_items, function (item) {
            return item.meta ? item.meta.is_selected : false;
        }).length;
    }

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
}
