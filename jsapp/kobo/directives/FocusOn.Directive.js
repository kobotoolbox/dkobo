// http://stackoverflow.com/a/18295416

kobo.directive('focusOn', function($timeout) {
   return function(scope, elem, attr) {
      scope.$on(attr.focusOn, function(e) {
          $timeout(function() {
            elem[0].focus();
          });
      });
   };
});