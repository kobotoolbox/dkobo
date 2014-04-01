/*exported AssetsController*/
/*global XLF*/
/*global _*/
'use strict';
function AssetsController($scope, $rootScope, $resource, $restApi, $timeout, $filter) {
    var assets = $restApi.create_question_api($scope);
    $scope.sort_criteria = 'date_modified';
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    $scope.filters = {};

    assets.list();

    $scope.toggle_response_list = function (item) {
        if (item.type !== 'select_one' && item.type !== 'select_all') {
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

        _.each($scope.info_list_items, function (item) {
            item.meta.is_selected = false;
            item.meta.question_class = 'questions__question';
        });

        _.each(filter($scope.info_list_items, $scope.filters), function (item) {
            item.meta.is_selected = $scope.select_all;
            item.meta.question_class = new_class;
        });
    }

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

    $scope.get_selected_amount = function () {
        var amount = _.filter($scope.info_list_items, function (item) {
            return item.meta ? item.meta.is_selected : false;
        }).length;

        if (amount > 1 || amount === 0) {
            return amount + ' questions';
        } else {
            return amount + ' question';
        }
    };

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Question Library';
}