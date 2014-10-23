/* exported ConfigurationService */
'use strict';

kobo.service('$configuration', function () {
    this.sections = function () {
        return [
            {
                'title': 'Forms',
                'icon': 'fa-file-text-o',
                'name': 'forms'
            },
            {
                'title': 'Question Library',
                'icon': 'fa-folder',
                'name': 'library/questions'
            // },
            // {
            //     'title': 'Admin',
            //     'icon': 'fa-cog',
            //     'name': 'admin'
            // },
            // {
            //     'title': 'Import CSV',
            //     'icon': 'fa-cog',
            //     'name': 'import/csv'
            }
        ];
    };
});
