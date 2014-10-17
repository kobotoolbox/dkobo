kobo.directive('itemList', function ($api) {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: staticFilesUri + 'templates/ItemList.Directive.Template.html',
        transclude: true,
        scope: {
            restApi: '@',
            filters: '=',
            sortCriteria: '=',
            baseClass: '@',
            quickEdit: '@',
            fullEdit: '@',
            fullEditClass: '@',
            additionalSelectOperations: '=',
            canDelete: '@'
        },
        compile: function (elem, attrs, transcludeFn) {
            var api, initialize_items;

            return {
                pre: function (scope) {
                    transcludeFn(scope, function (clone) {
                        elem.find('span[inner-transclude]').append(clone)
                    });

                    if (scope.restApi) {
                        // scope is passed for compatibility with old API interface. should be refactored out
                        api = $api[scope.restApi];
                        scope.items = api.list();
                    }
                },
                post: function (scope) {
                    scope.transclude = transcludeFn;

                    function deselect_all(item) {
                        var i,
                            more_than_one_selected = false,
                            currently_selected = item.meta.isSelected,
                            current;

                        for (i = 0; i < scope.items.length; i++) {
                            current = scope.items[i];
                            if (current != item) {
                                more_than_one_selected = more_than_one_selected || (currently_selected && current.meta.isSelected);
                            }
                            current.meta.additionalClasses = '';
                            current.meta.isSelected = false;
                        }
                        return more_than_one_selected
                    }

                    scope.toggleSelected = function (item, $event) {
                        var i,
                            currently_selected = item.meta.isSelected,
                            more_than_one_selected = false,
                            select_question,
                            select_all = true;

                        if (!($event.ctrlKey || $event.metaKey)) {
                            more_than_one_selected = deselect_all(item);
                        }

                        select_question = more_than_one_selected || !currently_selected;
                        item.meta.isSelected = select_question;
                        item.meta.additionalClasses = select_question ? scope.baseClass + '--selected' : '';

                        for (i = 0; i < scope.items.length; i++) {
                            select_all = select_all && scope.items[i].meta.isSelected;
                        }

                        scope.is_updating_select_all = true;
                        if (scope.select_all === select_all) {
                            scope.is_updating_select_all = false;
                        } else {
                            scope.select_all = select_all
                        }

                        if (typeof scope.additionalSelectOperations !== 'undefined') {
                            scope.additionalSelectOperations(scope.items)
                        }
                    };

                    scope.removeItem = function (item, $event) {
                        $event.stopPropagation();
                        if (!api) {
                            throw 'No API. To use this functionality you must specify the rest-api attribute.'
                        }
                        scope.toggleSelected(item, {});
                        item.$remove();
                        api.remove(item.id);
                    };

                    scope.updateModel = function (item) {
                        api.save(item);
                    }
                }
            }
        }
    }
});