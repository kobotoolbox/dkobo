kobo.directive('itemFilters', ['$api', '$filter', '$miscUtils', function ($api, $filter, $miscUtils) {
    return {
        restrict: 'E',
        templateUrl: staticFilesUri + 'templates/ItemFilters.Template.html',
        replace: true,
        scope: {
            api: '@',
            filters: '=',
            sorter: '=',
            toggle: '=',
            canSelectAll: '@'
        },
        link: function (scope) {
            scope.name = scope.api.substring(0, scope.api.length -1);

            function select_all() {
                var new_class = scope.select_all ? scope.api + '__' + scope.name + '--selected' : '';
                var filter = $filter('filter');

                if (!scope.is_updating_select_all) {
                    _.each($api[scope.api].items, function (item) {
                        item.meta.isSelected = false;
                        item.meta.additionalClasses = '';
                    });

                    _.each(filter($api[scope.api].items, scope.filters), function (item) {
                        item.meta.isSelected = scope.select_all;
                        item.meta.additionalClasses = new_class;
                    });
                }

                scope.is_updating_select_all = false;
            }

            function deselect_not_shown() {
                var filter = $filter('filter'),
                    not_shown = _.difference($api[scope.api].items, filter($api[scope.api].items, scope.filters));

                _.each(not_shown, function (item) {
                    item.meta.isSelected = false;
                    item.meta.additionalClasses = '';
                });
            }

            scope.delete_selected = function () {
                if (!$miscUtils.confirm('are you sure you want to delete ' + scope.get_selected_amount() + '?')) {
                    return;
                }
                _.each($api[scope.api].items, function (item) {
                    if (item.meta.isSelected) {
                        $api[scope.api].remove(item);
                    }
                });

                $api[scope.api].items = _.filter($api[scope.api].items, function (item) {
                    return !item.meta.isSelected
                });
            };

            scope.$watch('filters.label', function () {
                deselect_not_shown();
            });

            scope.$watch('select_all', function () {
                if (scope.select_all === null || scope.silent_select) {
                    scope.silent_select = false;
                    return;
                }
                select_all();
            });

            scope.toggle = function (items) {
                var selectAll = _.filter(items, function (item) {
                    return item.meta.isSelected;
                }).length === items.length;
                if (scope.select_all !== selectAll) {
                    scope.silent_select = true;
                    scope.select_all = selectAll;
                }

                var selectQuestions = _.filter(items, function (item) {
                    return item.type === 'select_one' || item.type === 'select_multiple'
                });
                var showResponses = _.filter(selectQuestions, function (item) {
                    return item.meta.show_responses;
                }).length === selectQuestions.length;

                if (scope.show_responses !== showResponses) {
                    scope.silent_show_responses = true;
                    scope.show_responses = showResponses;
                }
            };

            scope.showToggleResponses = function () {
                return _.filter($api[scope.api].items, function (item) {
                    return item.type === 'select_one' || item.type === 'select_multiple';
                }).length;
            };

            scope.$watch('show_responses', function () {
                if (typeof scope.show_responses === 'undefined' || scope.silent_show_responses) {
                    scope.silent_show_responses = false;
                    return;
                }

                _.each($api[scope.api].items, function (item) {
                    $miscUtils.toggle_response_list(item, scope.show_responses);
                });
            });


            scope.get_selected_count = function () {
                return _.filter($api[scope.api].items, function (item) {
                    return item.meta ? item.meta.isSelected : false;
                }).length;
            };

            scope.get_selected_amount = function () {
                var amount = scope.get_selected_count();

                if (amount > 1 || amount === 0) {
                    return amount + ' questions';
                } else {
                    return amount + ' question';
                }
            };

        }
    };
}]);