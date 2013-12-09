var kobo = angular.module('dkobo', [
  'ngRoute'
  ]);

kobo.directive('topLevelMenu', TopLevelMenuDirective);
kobo.directive('infoList', InfoListDirective);

kobo.config(['$routeProvider',
  function ($routeProvider) {
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

    $routeProvider.when('/assets', {
      templateUrl: staticFilesUri + 'templates/Forms.Template.html',
      controller: 'AssetsController'
    });

    $routeProvider.when('/admin', {
      templateUrl: staticFilesUri + 'templates/Admin.Template.html',
      controller: 'AdminController'
    });

    $routeProvider.otherwise({
      redirectTo: '/dashboard'
    });
  }]);