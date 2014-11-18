/* exported BuilderController */
/* global dkobo_xlform */
'use strict';

function BuilderController($scope, $rootScope, $routeParams, $routeTo, $miscUtils, $userDetails, $api, $q) {
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

    $scope.survey_loading = true;

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

    // jshint validthis: true
    var surveyDraftApi = $api.surveys;

    function saveCallback() {
        if (this.validateSurvey()) {
            try {
                var survey = this.survey.toCSV();
            } catch (e) {
                $miscUtils.alert(e.message, "Error");
                throw e;
            }
            return surveyDraftApi.save({
                id: $scope.routeParams.id !== 'new' && $scope.routeParams.id,
                body: survey,
                description: this.survey.get('description'),
                name: this.survey.settings.get('form_title')
            }).then(function() {
                $rootScope.deregisterLocationChangeStart && $rootScope.deregisterLocationChangeStart();
                $(window).unbind('beforeunload');
                $routeTo.forms();
            }, function(response) {
                $miscUtils.alert('a server error occured: \n' + response.statusText, 'Error');
            });

        }
        var deferred = $q.defer();
        deferred.resolve();
        return deferred.promise;
    }


    $scope.displayQlib = false;
    if ($scope.routeParams.id && $scope.routeParams.id !== 'new'){
        // url points to existing survey_draft
        surveyDraftApi.get({id: $scope.routeParams.id}).then(function builder_get_callback(response) {
            var warnings = [];

            if (window.importFormWarnings) {
                warnings = window.importFormWarnings || [];
                // empty out the global warnings object
                window.importFormWarnings = [];
            }

            $scope.xlfSurvey = dkobo_xlform.model.Survey.load(response.body);
            // temporarily saving response in __djangoModelDetails
            $scope.xlfSurvey.__djangoModelDetails = response;
            $scope.xlfSurveyApp = dkobo_xlform.view.SurveyApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback, warnings: warnings});
            $scope.xlfSurveyApp.render();
        });
    } else {
        // url points to new survey_draft
        $scope.xlfSurvey = new dkobo_xlform.model.Survey();
        $scope.xlfSurveyApp = dkobo_xlform.view.SurveyApp.create({el: 'section.form-builder', survey: $scope.xlfSurvey, ngScope: $scope, save: saveCallback});
        $scope.xlfSurveyApp.render();
    }

    $scope.add_row_to_question_library = function (row) {
        var survey = dkobo_xlform.model.Survey.create();
        survey.rows.add(row);

        var resource = $api.questions;
        resource.save({body: survey.toCSV(), asset_type: 'question'}, function () {
            $miscUtils.alert('<p><strong>Your question has been saved to your question library.</strong></p><p>You can now find this question in the library sidebar on the right. To reuse it, just drag-and-drop it into any of your forms.</p><p>To edit or remove questions from your library, choose Question Library from the menu. </p>', 'Success!');
            $scope.refresh();
        });
    };

}
