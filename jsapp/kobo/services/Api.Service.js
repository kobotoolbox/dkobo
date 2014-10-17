/*
* get ({id: id})
* list ()
* save (item)
* remove (item)
* */

kobo.service('$api', function ($restApi) {
    this.questions = $restApi.createQuestionApi();
    this.surveys = $restApi.createSurveyDraftApi();
    this.tags = $restApi.createTagsApi();
});
