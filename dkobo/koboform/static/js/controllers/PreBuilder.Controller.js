function PreBuilderController ($scope, $routeTo, $miscUtils, $location) {
    $scope.goto_builder = function () {
        $routeTo.builder();
    }

    $miscUtils.bootstrapFileUploader(1);

    $miscUtils.changeFileUploaderSuccess(function (response) {
        $location.path('/builder/' + response.survey_draft_id);
    });
}