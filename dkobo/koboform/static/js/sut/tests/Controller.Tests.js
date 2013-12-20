/*global describe*/
/*global it */
/*global expect*/
/*global inject*/
'use strict';
describe ('Controllers', function () {
       
    describe ('Forms Controller', function () {
        it('should initialize $rootScope and $scope correctly', inject(function($controller) {
            var $rs = {},
                $scope = {},
                hello = {hello: 'world'},
                $resource = function () {
                    return {
                        get: function() { return hello; }
                    };
                };

            $controller('FormsController', {
                $rootScope: $rs,
                $scope: $scope,
                $resource: $resource
            });
            expect($rs.canAddNew).toBe(true);
            expect($rs.activeTab).toBe('Forms');

            expect($scope.infoListItems).toBe(hello);
        }));
    });
});