/* exported RouteToService */
/* global _ */
'use strict';

kobo.service('$routeTo', ['$location', function ($location) {
    var $$path = _.bind($location.path, $location);

    this.forms = function () {
        $$path('/forms');
    };

    this.builder = function () {
        $$path('/builder/new')
    }

    this.question_library = function () {
        $$path('/library/questions')
    }

    this.external = function (url) {
        window.location = url;
    };
}]);
