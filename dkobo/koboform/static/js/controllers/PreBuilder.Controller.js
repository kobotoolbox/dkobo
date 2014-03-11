function PreBuilderController ($scope, $routeTo) {
    $scope.goto_builder = function () {
        $routeTo.builder();
    }
}