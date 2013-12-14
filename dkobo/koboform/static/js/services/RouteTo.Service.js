/* exported RouteTo */
'use strict';
function RouteToService($location) {
    var $$path = _.bind($location.path, $location);

    this.forms = function () {
        $$path('/forms');
    };
}