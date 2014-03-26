/*exported AssetsController*/
'use strict';
function AssetsController($scope, $rootScope, $resource, $restApi) {
    var assets = $restApi.create_question_api();
    $scope.sort_criteria = '-date';

    assets.query(function (results) {

        for (var i = 0; i < results.length; i++) {
            results[i].meta = {
                show_responses: false,
                is_selected: false,
                question_class: 'questions__question',
                question_type_class: 'question__type',
                question_type_icon: 'fa fa-caret-right',
                question_type_icon_class: 'question__type-icon'
            }

            // for demo purposes

            results[i].date = new Date().setDate(new Date().getDate() - i);
        }
        $scope.info_list_items = results;
    });

    $scope.toggle_response_list = function (item) {
        if (item.meta.show_responses) {
            item.meta.show_responses = false;
            item.meta.question_type_class = 'question__type'
            item.meta.question_type_icon = 'fa fa-caret-right'
            item.meta.question_type_icon_class = 'question__type-icon'
        } else {
            item.meta.question_type_class = 'question__type question__type--expanded';
            item.meta.question_type_icon_class = 'question__type-icon question__type--expanded-icon';
            item.meta.question_type_icon = 'fa fa-caret-down';
            item.meta.show_responses = true;
        }
    }

    $scope.select_all = null;

    $scope.$watch('select_all', function () {
        if ($scope.select_all === null) {
            return;
        }
        var new_class = $scope.select_all ? 'questions__question questions__question--selected' : 'questions__question';

        _.each($scope.info_list_items, function (item) {
            item.meta.is_selected = $scope.select_all;
            item.meta.question_class = new_class;
        });
    });

    $scope.$watch('show_responses', function () {
        if (typeof $scope.show_responses === 'undefined') {
            return;
        }
        var show_responses = $scope.show_responses,
            new_question_type_class,
            new_question_type_icon,
            new_question_type_icon_class;

        if (show_responses) {
            new_question_type_class = 'question__type question__type--expanded';
            new_question_type_icon = 'fa fa-caret-down';
            new_question_type_icon_class = 'question__type-icon question__type--expanded-icon';
        } else {
            new_question_type_class = 'question__type';
            new_question_type_icon = 'fa fa-caret-right';
            new_question_type_icon_class = 'question__type-icon';
        }

        _.each($scope.info_list_items, function (item) {
            item.meta.show_responses = show_responses;
            item.meta.question_type_class = new_question_type_class;
            item.meta.question_type_icon = new_question_type_icon;
            item.meta.question_type_icon_class = new_question_type_icon_class;
        });
    });

    $scope.get_selected_amount = function () {
        var amount = _.filter($scope.info_list_items, function (item) {
            return item.meta.is_selected;
        }).length

        if (amount > 1 || amount === 0) {
            return amount + ' questions';
        } else {
            return amount + ' question';
        }
    }

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Question Library';
}