/* exported TopLevelMenuDirective */
/* global staticFilesUri */
'use strict';

function TopLevelMenuDirective ($userDetails, $configuration) {
    return {
        restrict:'A',
        templateUrl: staticFilesUri + 'templates/TopLevelMenu.Template.html',
        scope: {
            activeTab: '='
        },
        link: function (scope) {
            var userDetails = $userDetails;
            if ($userDetails) {
                scope.user = {
                    name: userDetails.name ? userDetails.name : 'KoBoForm User',
                    avatar: userDetails.gravatar ? userDetails.gravatar: (staticFilesUri + '/img/avatars/example-photo.jpg')
                };
            } else {
                scope.user = {
                    name: 'KoBoForm User',
                    avatar: staticFilesUri + '/img/avatars/example-photo.jpg'
                };
            }

            scope.sections = $configuration.sections();

            scope.isActive = function (name) {
                return name === scope.activeTab ? 'is-active' : '';
            };
        }
    };
}