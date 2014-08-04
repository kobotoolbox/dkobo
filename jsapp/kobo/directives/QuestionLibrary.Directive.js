function QuestionLibraryDirective($restApi) {
    return {
        templateUrl: staticFilesUri + 'templates/QuestionLibrary.Directive.Template.html',
        scope: {
            clickHandler: '&',
            currentItem: '='
        },
        link: function (scope, element) {
            var sort_ul = element.find('ul');

            $restApi.create_question_api(scope).list();
            scope.handle_click = function (item) {
                scope.clickHandler({ item: item});
            };
            scope.hide_library_popup = function () {
                scope.$parent.displayQlib = false;
            };

            scope.set_item = function (item) {
                scope.currentItem = item;
            };

            sort_ul.sortable({
                items: "> li",
                connectWith: ".survey-editor__list",
                helper: 'clone',
                start: function () {
                    sort_ul.find('li:hidden').show();
                }
            });
        }
    };
}