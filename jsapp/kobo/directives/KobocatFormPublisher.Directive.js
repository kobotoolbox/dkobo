function KobocatFormPublisherDirective($restApi, $miscUtils) {
    return {
        scope: {
            item: '='
        },
        templateUrl: staticFilesUri + 'templates/KobocatFormPublisher.Template.html',
        link: function (scope, element, attributes) {
            var dialog = element.find('.forms__kobocat__publisher');
            scope.publish = function () {
                function success (results, headers) {
                    scope.close();
                    $miscUtils.alert('Survey Publishing succeeded');
                }
                function fail (response) {
                    scope.close();
                    $miscUtils.alert('Survey Publishing failed. <br/><br/>' + response.data.text);
                }

                $restApi.createSurveyDraftApi(scope.item.id)
                    .publish({title:scope.form_label, id_string: dkobo_xlform.model.utils.sluggifyLabel(scope.form_name)}, success, fail);
            };

            scope.open = function () {
                scope.show_publisher = true;
                dialog.dialog('open');
            };
            scope.close = function () {
                scope.show_publisher = false;
                dialog.dialog('close');
            };

            scope.show_publisher = false;
            dialog.dialog({
                modal: true,
                height: 400,
                width: 600,
                autoOpen: false,
                title: 'Publish Survey',
                draggable: false,
                resizable: false,
                buttons: {
                    'Done': scope.publish,
                    'Cancel': scope.close
                }
            });
        }
    }
}