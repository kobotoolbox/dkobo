/* global angular */
/* global TopLevelMenuDirective */
'use strict';

var kobo = angular.module('dkobo', [
  'ngRoute',
  'ngCookies',
  'ngResource'
  ]);

kobo.directive('topLevelMenu', TopLevelMenuDirective);
kobo.directive('infoList', InfoListDirective);
kobo.directive('koboformBuilder', BuilderDirective);

kobo.factory('$userDetails', userDetailsFactory);
kobo.factory('$restApi', restApiFactory);

kobo.service('$routeTo', RouteToService);
kobo.service('$configuration', ConfigurationService);


kobo.config(function ($routeProvider, $httpProvider) {

    //http://django-angular.readthedocs.org/en/latest/integration.html

    $httpProvider.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

    $routeProvider.when('/dashboard', {
      templateUrl: staticFilesUri + 'templates/Dashboard.Template.html',
      controller: function ($scope) {
        $scope.additionalClasses = 'content--centered';
      }
    });

    $routeProvider.when('/forms', {
      templateUrl: staticFilesUri + 'templates/Forms.Template.html',
      controller: 'FormsController'
    });

    $routeProvider.when('/builder/:id?', {
      template: "<section koboform-builder class='form-builder'></section>",
      controller: 'BuilderController'
    });

    $routeProvider.when('/assets', {
      templateUrl: staticFilesUri + 'templates/Forms.Template.html',
      controller: 'AssetsController'
    });

    $routeProvider.when('/admin', {
      templateUrl: staticFilesUri + 'templates/Admin.Template.html',
      controller: 'AdminController'
    });

    $routeProvider.when('/import/csv', {
      templateUrl: staticFilesUri + 'templates/ImportCSV.Template.html',
      controller: 'ImportController'
    });

    $routeProvider.otherwise({
      redirectTo: '/dashboard'
    });
  });

kobo.run(function ($http, $cookies) {
    $http.defaults.headers.post['X-CSRFToken'] = $cookies.csrftoken;
});
