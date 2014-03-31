/*exported BuilderController*/
'use strict';

function BuilderController($scope, $rootScope, $routeParams, $miscUtils, $location) {
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
    }

    /*jshint validthis: true */
    var surveyDraftApi = $restApi.createSurveyDraftApi(scope.routeParams.id);

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

    if (scope.routeParams.id && scope.routeParams.id != 'new'){
        surveyDraftApi.get({id: scope.routeParams.id}, function builder_get_callback(response) {
            scope.xlfSurvey = XLF.createSurveyFromCsv(response.body);
            // temporarily saving response in __djangoModelDetails
            scope.xlfSurvey.__djangoModelDetails = response;
            new SurveyApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
        });
    } else {
        new SurveyApp({el: element, survey: scope.xlfSurvey, save: saveCallback}).render();
    }
}
