kobo.directive ('tags', function () {
    return {
        scope: {
            model: '='
        },
        link: function (scope,element) {
            // Transform the plain text input into a tags input box now, even
            // though the existing tags might not be loaded yet
            element.tagsInput({
                width: '700px',
                height: '45px',
                autocomplete_url: 'na', //this needs to be !=undefined for autocomplete to work
                autocomplete: {
                    source: _.sortBy(scope.model.available, function (name){return name.toLowerCase(); }),
                    minLength: 0
                },
                onChange: function () {
                    scope.model.selected = $(this).val();
                }
            });

            // Watch for the existing tags to be loaded
            var clearSourceWatch = scope.$watch('model.available.length', function () {
                if (scope.model.available.length > 0) {
                    // The existing tags have been received! Import them into
                    // the tags input element and stop watching
                    element.importTags(scope.model.selected);
                    clearSourceWatch();
                }
            })
        }
    }
});
