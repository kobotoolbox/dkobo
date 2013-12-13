function BuilderDirective($rootScope) {
    return {
        link: function(scope, element, attrs){
            function saveCb(){
                if(this.validateSurvey()) {
                    $.ajax({
                        url: "/koboform/survey_draft/new",
                        method: "POST",
                        data: {
                            body: this.survey.toCSV(),
                            description: this.survey.get("description"),
                            title: this.survey.settings.get("form_title")
                        },
                        headers: {
                            "X-CSRFToken": $("meta[name=csrf_token]").prop("content")
                        }
                    }).done(function(response){
                        console.log("Saved survey- ", response);
                        console.log("Redirect to '/#/forms'?");
                    });
                }
            }
            new SurveyTemplateApp({el: element, survey: scope.xlfSurvey, save: saveCb}).render();
        }
    };
}
