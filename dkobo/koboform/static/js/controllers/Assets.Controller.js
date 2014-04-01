/*exported AssetsController*/
/*global XLF*/
/*global _*/
'use strict';
function AssetsController($scope, $rootScope, $resource, $restApi, $timeout) {
    var assets = $restApi.create_question_api();
    $scope.sort_criteria = 'date_modified';
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    $scope.filters = {};

    assets.query(function (inputs) {
        $scope.info_list_items = inputs;

        function create_survey(item) {
            item.backbone_model = XLF.createSurveyFromCsv(item.body);
        }

        function set_defaults(item) {
            item.meta = {
                show_responses: false,
                is_selected: false,
                question_class: 'questions__question',
                question_type_class: 'question__type',
                question_type_icon: 'fa fa-caret-right',
                question_type_icon_class: 'question__type-icon'
            };
        }

        function get_props_from_row(item) {
            var row = item.backbone_model.rows.at(0);

            if(row) {
                item.label = row.getValue('label');
                item.type = row.get("type").get("typeId");

                var list = row.getList();
                if (list) {
                    item.responses = list.options.map(function(option) {
                        return option.get("label");
                    });
                }
                results.push(row);

                // for demo purposes
                row.date = new Date().setDate(new Date().getDate() - i);
            }
        }

        var results = [];
        var i = 0;


        function timed_execution(item) {
            return $timeout(function () {
                set_defaults(item);
            }, 50).then(function () {
                create_survey(item);
            }).then(function () {
                get_props_from_row(item);
            }).then(function () {
                i++;
                if (i < $scope.info_list_items.length) {
                    timed_execution($scope.info_list_items[i]);
                }
            });
        }

        timed_execution($scope.info_list_items[i]);

    });

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