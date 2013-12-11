function BuilderDirective($rootScope) {
    return {
        link: function(scope, element, attrs){
            new SurveyTemplateApp({el: element, survey: scope.xlfSurvey}).render();
        }
    };
}
