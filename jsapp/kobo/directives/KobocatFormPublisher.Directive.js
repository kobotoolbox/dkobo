kobo.directive ('kobocatFormPublisher', function ($api, $miscUtils, $routeTo, $surveySerializer) {
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
                $api.surveys
                    .publish({id: scope.item.id, title:scope.form_label, id_string: id}, success, fail);
            };

            scope.form_label = scope.item.name;

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
                if (item.formid) {
                    return item.formid;
                }
                if (item.body) {
                    var s = $surveySerializer.deserialize(item.body);

                    return item.formid = s.settings.form_id;
                }
            };
            scope.form_name = scope.get_form_id(scope.item);

            dialog.dialog({
                modal: true,
                height: 350,
                width: 600,
                autoOpen: false,
                title: 'Deploy as New Survey Project',
                draggable: false,
                resizable: false,
                buttons: [
                    {
                        text: "Done",
                        "class": 'save-button',
                        click: scope.publish
                    },
                    {
                        text: "Cancel",
                        "class": 'cancel-button',
                        click: scope.close
                    }
                ],
            });
        }
    }
});