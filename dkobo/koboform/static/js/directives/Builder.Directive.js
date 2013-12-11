function BuilderDirective($rootScope) {
    return {
        templateUrl: staticFilesUri + 'templates/Builder.Template.html',
        link: function(scope, element, attrs){
            new SurveyTemplateApp({el: element, survey: scope.xlfSurvey}).render();
        }
    };
}
