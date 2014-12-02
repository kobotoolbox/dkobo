/*
* get ({id: id})
* list ()
* save (item)
* remove (item)
* items: bind element
* */

kobo.service('$api', ['$restApi', function ($restApi) {
    this.questions = $restApi.createQuestionsApi();
    this.surveys = $restApi.createSurveyDraftsApi();
    this.tags = $restApi.createTagsApi();
}]);
