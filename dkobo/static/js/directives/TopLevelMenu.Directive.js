function TopLevelMenuDirective () {
  return {
    restrict:'A',
    templateUrl: staticFilesUri + 'templates/TopLevelMenu.Template.html', 
    scope: {
        activeTab: '='
    },
    link: function (scope, element, attributes) {
        scope.user = {
            name: 'Chris Nager',
            avatar: 'chris-nager.jpg'
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
            }
        ];

        scope.isActive = function (name) {
            return name === scope.activeTab ? 'is-active' : '';
        }
    }
  }
}