function KobocatFormPublisherDirective($restApi, $miscUtils, $routeTo) {
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
                    $routeTo.external(results.published_form_url);
                }
                function fail (response) {
                    scope.show_form_name_exists_message = true;
                    scope.error_message = 'Survey Publishing failed: ' + (response.data.text || response.data.error);
                }

                var id = scope.form_name ? dkobo_xlform.model.utils.sluggifyLabel(scope.form_name) : '';
                $restApi.createSurveyDraftApi(scope.item.id)
                    .publish({title:scope.form_label, id_string: id}, success, fail);
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
            scope.show_form_name_exists_message = false;
            scope.get_form_id = function (item) {
                name = item.body.split('\n').pop().split(',')[2];
                return name.substring(1, name.length -1);
            };

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