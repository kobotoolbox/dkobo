kobo.directive('questionDetails', ['$miscUtils', function ($miscUtils) {
    return {
        restrict: 'E',
        templateUrl: staticFilesUri + 'templates/QuestionDetails.Template.html',
        link: function (scope) {
            scope.toggle_response_list = $miscUtils.toggle_response_list
        }
    }
}]);