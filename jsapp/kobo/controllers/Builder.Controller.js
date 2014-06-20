/* exported BuilderController */
/* global dkobo_xlform */
'use strict';

function BuilderController($scope, $rootScope, $routeParams, $restApi, $routeTo, $miscUtils, $location, $userDetails) {
    $rootScope.activeTab = 'Forms';
    $scope.routeParams = $routeParams;
    var forceLeaveConfirmation = !$userDetails.debug;
    function handleUnload(event) {
        if ($miscUtils.confirm('Are you sure you want to leave? you will lose any unsaved changes.')){
            $rootScope.deregisterLocationChangeStart();
            $(window).unbind('beforeunload');
        } else {
            $miscUtils.preventDefault(event);
        }
    }

    if (forceLeaveConfirmation) {
        $rootScope.deregisterLocationChangeStart = $rootScope.$on('$locationChangeStart', handleUnload);
        $(window).bind('beforeunload', function(){
            return 'Are you sure you want to leave?';
        });
    }

    $scope.add_item = function (position) {
        //add item.backbone_model contains the survey representing the question
        $scope.xlfSurvey.insertSurvey($scope.currentItem.backbone_model, position);
    };

    /*jshint validthis: true */
    var surveyDraftApi = $restApi.createSurveyDraftApi($scope.routeParams.id);

    function saveCallback() {
        if (this.validateSurvey()) {
            try {
                var survey = this.survey.toCSV();
            } catch (e) {
                $miscUtils.alert(e.message, "Error");
                throw e;
            }

            surveyDraftApi.save({
                body: survey,
                description: this.survey.get('description'),
                name: this.survey.settings.get('form_title')
            }, function() {
                $rootScope.deregisterLocationChangeStart && $rootScope.deregisterLocationChangeStart();
                $(window).unbind('beforeunload');
                $routeTo.forms();
            }, function(response) {
                $miscUtils.alert('a server error occured: \n' + response.statusText, 'Error');
            });
        }
    }

    $scope.displayQlib = false;

    if ($scope.routeParams.id && $scope.routeParams.id !== 'new'){
        // url points to existing survey_draft
        surveyDraftApi.get({id: $scope.routeParams.id}, function builder_get_callback(response) {
            $scope.xlfSurvey = dkobo_xlform.model.Survey.load(response.body);
            // temporarily saving response in __djangoModelDetails
            $scope.xlfSurvey.__djangoModelDetails = response;
            $scope.xlfSurveyApp = dkobo_xlform.view.SurveyApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
            $scope.xlfSurveyApp.render();
        });
    } else {
        // url points to new survey_draft
        $scope.xlfSurvey = new dkobo_xlform.model.Survey();
        $scope.xlfSurveyApp = dkobo_xlform.view.SurveyApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
        $scope.xlfSurveyApp.render();
    }

    $scope.add_row_to_question_library = function (row) {
        var survey = dkobo_xlform.model.Survey.create()
        survey.rows.add(row)

        var resource = $restApi.create_question_api($scope);
        resource.save({body: survey.toCSV(), asset_type: 'question'}, function () {
            $miscUtils.alert('Question added to library', 'Success!!');
        });
    };
}
