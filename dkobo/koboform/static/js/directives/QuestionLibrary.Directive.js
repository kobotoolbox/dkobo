function QuestionLibraryDirective($restApi) {
    return {
        templateUrl: staticFilesUri + 'templates/QuestionLibrary.Directive.Template.html',
        scope: {
            clickHandler: '&'
        },
        link: function (scope) {
            $restApi.create_question_api(scope).list();
            scope.handle_click = function (item) {
                scope.clickHandler({ item: item });
            };
        }
    };
}