/* exported ConfigurationService */
'use strict';

function ConfigurationService() {
    this.sections = function () {
        return [
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
                'title': 'Import CSV',
                'icon': 'fa-cog',
                'name': 'import/csv'
            }
        ];
    };
}