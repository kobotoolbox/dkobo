kobo.directive ('tags', function () {
    return {
        scope: {
            model: '='
        },
        link: function (scope,element) {

            var clearSourceWatch = scope.$watch('model.available.length', function () {
                element.val(scope.model.selected);
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
                clearSourceWatch();
            })
        }
    }
});