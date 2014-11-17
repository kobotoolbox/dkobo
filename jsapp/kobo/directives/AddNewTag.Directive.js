kobo.directive('addNewTag', ['$api', function ($api) {
    return {
        restrict: 'E',
        templateUrl: staticFilesUri + 'templates/AddNewTag.Template.html',
        link: function (scope) {
            scope.cancelAdd = function () {
                delete scope.newTagName;
                scope.isAdding = false;
            };

            scope.addNewTag__KeyDown = function ($event) {
                if ($event.which === 13) {
                    scope.addNewTag();
                } else if ($event.which === 27) {
                    scope.cancelAdd()
                }
            };

            scope.addNewTag = function () {
                var api = $api.tags;
                if(!scope.newTagName) {
                    return;
                }
                api.save({label: scope.newTagName});
                delete scope.newTagName;
                scope.isAdding = false;
            };

            scope.enableAdd = function () {
                scope.isAdding = true;
                scope.$broadcast('showAddBox');
            };
        }
    }
}]);