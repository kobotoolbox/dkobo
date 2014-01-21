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
kobo.service('$miscUtils', MiscUtilsService);


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
      templateUrl: staticFilesUri + 'templates/Assets.Template.html',
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
    $http.defaults.headers.common['X-CSRFToken'] = $cookies.csrftoken;
});

// jQuery.fileupload for importing forms to the user's form list.
$(function(){
    $('.btn--header-import').eq(0).fileupload({
        headers: {
            "X-CSRFToken": $('meta[name="csrf-token"]').attr('content')
        },
        add: function (e, data) {
            // maybe display some feedback saying the upload is starting...
            log(data.files[0].name + " is uploading...")
            data.submit().success(function(result){
                window.importedSurveyDraft = JSON.parse(result);
            })
        }
    });
})
