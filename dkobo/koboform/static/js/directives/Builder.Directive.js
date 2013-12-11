function BuilderDirective($rootScope) {
    return {
        link: function(scope, element, attrs){
            new SurveyApp({el: element, survey: scope.xlfSurvey}).render();
        }
    };
}
