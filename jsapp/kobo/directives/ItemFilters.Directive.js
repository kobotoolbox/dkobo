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

            function select_all(select_all) {
                var new_class = select_all ? scope.api + '__' + scope.name + '--selected' : '';
                var filter = $filter('itemFilter');

                if (!scope.is_updating_select_all) {
                    _.each($api[scope.api].items, function (item) {
                        item.meta.isSelected = false;
                        item.meta.additionalClasses = '';
                    });

                    _.each(filter($api[scope.api].items, scope.filters), function (item) {
                        item.meta.isSelected = select_all;
                        item.meta.additionalClasses = new_class;
                    });
                }

                scope.is_updating_select_all = false;
            }

            function deselect_not_shown() {
                var filter = $filter('itemFilter'),
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
                var items =[];
                _.each($api[scope.api].items, function (item) {
                    if (item.meta.isSelected) {
                        items.push(item);
                    }
                });

                $api[scope.api].remove(items.length === 1 ? items[0] : items);
            };

            scope.$watch('filters', function () {
                deselect_not_shown();
            }, true);

            scope.allSelected = function () {
                var items = $api[scope.api].items;
                return items && items.length && _.filter(items, function (item) {
                    return item.meta.isSelected;
                }).length === items.length;
            };

            scope.toggleSelectAll = function () {
                select_all(!scope.allSelected());
            };

            scope.toggle = function (items) {
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