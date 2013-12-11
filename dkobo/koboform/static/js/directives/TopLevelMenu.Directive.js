function TopLevelMenuDirective () {
  return {
    restrict:'A',
    templateUrl: staticFilesUri + 'templates/TopLevelMenu.Template.html', 
    scope: {
        activeTab: '='
    },
    link: function (scope, element, attributes) {
        var userDetails = window.userDetails || {};
        scope.user = {
            name: userDetails.name || 'KoBoForm User',
            avatar: userDetails.gravatar || (staticFilesUri + '/img/avatars/example-photo.jpg')
        };

        scope.sections = [
            {
                'title': 'Forms',
                'icon': 'fa-file-text-o',
                'name': 'forms'
            },
            {
                'title': 'Assets',
                'icon': 'fa-folder',
                'name': 'assets'
            },
            {
                'title': 'Admin',
                'icon': 'fa-cog',
                'name': 'admin'
            },
            {
                title: 'Import CSV',
                icon: 'fa-cog',
                name: 'import/csv'
            }
        ];

        scope.isActive = function (name) {
            return name === scope.activeTab ? 'is-active' : '';
        }
    }
  }
}