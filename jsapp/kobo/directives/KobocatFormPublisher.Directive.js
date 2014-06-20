function KobocatFormPublisherDirective($restApi, $miscUtils) {
    return {
        scope: {
            item: '&'
        },
        templateUrl: staticFilesUri + 'templates/KobocatFormPublisher.Template.html',
        link: function (scope, element, attributes) {
            scope.publish = function () {
                function success (results, headers) {
                    $miscUtils.alert('Survey Publishing succeeded');
                }
                function fail () {
                    $miscUtils.alert('Survey Publishing failed');
                }
                $restApi.createSurveyDraftApi(scope.item.id).publish({}, success, fail);
            };

            scope.open = function () {
                scope.show_publisher = true;
            };
            scope.cancel = function () {
                scope.show_publisher = false;
            };

            scope.show_publisher = false;
        }
    }
}