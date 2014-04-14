/*exported BuilderController*/
'use strict';

function BuilderController($scope, $rootScope, $routeParams, $restApi, $routeTo, $miscUtils, $location) {
    $rootScope.activeTab = 'Forms';
    $scope.routeParams = $routeParams;
    $rootScope.deregisterLocationChangeStart = $rootScope.$on('$locationChangeStart', handleUnload);
    function handleUnload(event) {
        if ($miscUtils.confirm('Are you sure you want to leave? you will lose any unsaved changes.')){
            $rootScope.deregisterLocationChangeStart();
            $(window).unbind('beforeunload');
        } else {
            $miscUtils.preventDefault(event);
        }
    }
    $(window).bind('beforeunload', function(){
        return 'Are you sure you want to leave?';
    });

    $scope.add_item = function (item) {
        //add item.backbone_model contains the survey representing the question
        $scope.xlfSurvey.insertSurvey(item.backbone_model, $("section.koboform__questionlibrary").data("rowIndex") || -1);
    }

    /*jshint validthis: true */
    var surveyDraftApi = $restApi.createSurveyDraftApi($scope.routeParams.id);

    function saveCallback() {
        if (this.validateSurvey()) {
            surveyDraftApi.save({
                    body: this.survey.toCSV(),
                    description: this.survey.get('description'),
                    name: this.survey.settings.get('form_title')
                }, function () {
                    $rootScope.deregisterLocationChangeStart && $rootScope.deregisterLocationChangeStart()
                    $(window).unbind('beforeunload');
                    $routeTo.forms()
                });
        }
    }

    $scope.displayQlib = false

    if ($scope.routeParams.id && $scope.routeParams.id !== 'new'){
        // url points to existing survey_draft
        surveyDraftApi.get({id: $scope.routeParams.id}, function builder_get_callback(response) {
            $scope.xlfSurvey = XLF.createSurveyFromCsv(response.body);
            // temporarily saving response in __djangoModelDetails
            $scope.xlfSurvey.__djangoModelDetails = response;
            $scope.xlfSurveyApp = SurveyApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
            $scope.xlfSurveyApp.render();
        });
    } else {
        // url points to new survey_draft
        $scope.xlfSurvey = new XLF.Survey()
        $scope.xlfSurveyApp = SurveyApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
        $scope.xlfSurveyApp.render();
    }

    $scope.add_row_to_question_library = function (row) {
        var survey = XLF.Survey.create()
        survey.rows.add(row)

        var resource = $restApi.create_question_api($scope);
        resource.save({body: survey.toCSV(), asset_type: 'question'}, function () {
            $miscUtils.alert('Question added to library', 'Success!!')
        });
    };
}
