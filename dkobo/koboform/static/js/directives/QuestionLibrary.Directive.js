function QuestionLibraryDirective() {
    return {
        controller: AssetsController,
        templateUrl: staticFilesUri + 'templates/QuestionLibrary.Directive.Template.html',
        scope: {
            clickHandler: '&'
        },
        link: function (scope) {
            scope.handle_click = function (item) {
                scope.clickHandler({ item: item });
            };
        }
    };
}