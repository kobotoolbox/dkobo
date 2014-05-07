/* exported RouteToService */
/* global _ */
'use strict';

function RouteToService($location) {
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
}