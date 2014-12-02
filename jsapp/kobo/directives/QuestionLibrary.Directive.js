kobo.directive ('koboformQuestionLibrary', ['$api', function ($api) {
    return {
        templateUrl: staticFilesUri + 'templates/QuestionLibrary.Directive.Template.html',
        scope: {
            clickHandler: '&',
            currentItem: '=',
            refreshEvent: '='
        },
        link: function (scope, element) {
            scope.filters = {
                label: '',
                tags: []
            };
            var sort_ul = element.find('ul');

            function activateSortable() {
                sort_ul.sortable({
                    items: "> div > li",
                    connectWith: ".survey-editor__list",
                    helper: 'clone',
                    start: function () {
                        sort_ul.find('li:hidden').show();
                    },
                    deactivate: function () {
                        sort_ul.sortable('cancel');
                    }
                });
            }

            var questions = scope.api = $api.questions;
            questions.list().then(activateSortable);

            scope.$parent.refresh = function () {
                questions.list().then(activateSortable);
            };

            scope.handle_click = function (item) {
                scope.clickHandler({ item: item});
            };
            scope.hide_library_popup = function () {
                scope.$parent.displayQlib = false;
            };

            scope.set_item = function (item) {
                scope.currentItem = item;
            };

            scope.tags = {
                selected: [],
                available: []
            };

            $api.tags.list().then(function () {
                scope.tags = {
                    available: $api.tags.items
                }
            });

            scope.$watch('tags.selected', function () {
                scope.filters.tags = _.pluck(scope.tags.selected, 'label');
            });
        }
    };
}]);
