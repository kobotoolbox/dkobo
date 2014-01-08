/* exported FormsController */
'use strict';

function FormsController ($scope, $rootScope, $resource) {
    var formsApi = $resource('api/survey_drafts/:id', {id: '@id'});

    $scope.infoListItems = formsApi.query();

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Forms';

    $scope.deleteSurvey = function (survey) {
        var id = survey.id;
        survey.$delete({id: survey.id}, function () {
            $scope.infoListItems = _.filter($scope.infoListItems, 
                function (item) { 
                    return item.id !== id; 
                }
            );
        });
        
    }
}