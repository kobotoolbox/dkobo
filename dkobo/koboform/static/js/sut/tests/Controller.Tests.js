/*global describe*/
/*global it */
/*global expect*/
/*global inject*/
'use strict';

describe ('Controllers', function () {
    var hello = {hello: 'world'},
        $rs, $scope,
        $resource = function () {
                        return {
                            query: function() { return hello; }
                        };
                    };


    function initializeController($controller, name) {
        $rs = {};
        $scope = {};

        $controller(name + 'Controller', {
            $rootScope: $rs,
            $scope: $scope,
            $resource: $resource,
            $routeParams: hello,
            $cookies: {csrftoken: 'test token'}
        });
    }

    describe ('Forms Controller', function () {
        it('should initialize $rootScope and $scope correctly', inject(function($controller) {
            initializeController($controller, 'Forms');

            expect($rs.canAddNew).toBe(true);
            expect($rs.activeTab).toBe('Forms');

            expect($scope.infoListItems).toBe(hello);
        }));
    });

    describe('Assets Controller', function () {
        it('should initialize $scope and $rootScope correctly', inject(function ($controller) {
            initializeController($controller, 'Assets');

            expect($rs.canAddNew).toBe(true);
            expect($rs.activeTab).toBe('Assets');

            expect($scope.infoListItems).toBe(hello);
        }));
    });

    describe('Header Controller', function () {
        it('should initialize $scope and $rootScope correctly', inject(function ($controller) {
            initializeController($controller, 'Header');
            
            expect($scope.pageIconColor).toBe('teal');
            expect($scope.pageTitle).toBe('Forms');
            expect($scope.pageIcon).toBe('fa-file-text-o');
            expect($scope.topLevelMenuActive).toBe('');
            expect($rs.activeTab).toBe('Forms');
        }));

        describe('$scope.toggleTopMenu', function () {
            it('should set the value of $scope.topLevelMenuActive to "is-active" when its value is an empty string',
                inject(function ($controller) {
                    initializeController($controller, 'Header');

                    $rs.topLevelMenuActive = '';
                    $scope.toggleTopMenu();

                    expect($rs.topLevelMenuActive).toBe('is-active');
                })
            );

            it('should set the value of $scope.topLevelMenuActive to an empty string when its value is "is-active"',
                inject(function ($controller) {
                    initializeController($controller, 'Header');

                    $rs.topLevelMenuActive = 'is-active';
                    $scope.toggleTopMenu();

                    expect($rs.topLevelMenuActive).toBe('');
                })
            );
        });
    });

    describe('Builder Controller', function () {
        it('should initialize $scope and $rootScope correctly', inject(function ($controller) {
            initializeController($controller, 'Builder');

            expect($rs.activeTab).toBe('Forms');
            expect($scope.routeParams).toBe(hello);
        }));
    });

    describe('Import Controller', function () {
        it('should initialize $scope and $rootScope correctly', inject(function ($controller) {
            initializeController($controller, 'Import');
            
            expect($scope.csrfToken).toBe('test token');
            expect($rs.canAddNew).toBe(false);
            expect($rs.activeTab).toBe('Import CSV');
        }));
    });
});