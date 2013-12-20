describe ('Directives', function () {
    var element;
    var $scope;

    beforeEach(module('dkobo'))
    beforeEach(module('templates/TopLevelMenu.Template.html'))
    beforeEach(module(function ($provide) {
        $provide.provider('$userDetails', function () { 
                    this.$get = function () {
                        return {
                            name: 'test name', 
                            gravatar: 'test avatar'
                        };
                    }
                });
            })
        );

    describe ('Top level menu Directive', function () {
        beforeEach(inject(function ($rootScope) {
            $scope = $rootScope;
        }));    

        it('should set $scope.user to values passed by $userDetails', 
            inject(function($compile) {



                var element = '<div top-level-menu></div>';
                element = $compile(element)($scope);
                $scope.$apply();

                expect(element.isolateScope().user.name).toBe('test name');
                expect(element.isolateScope().user.avatar).toBe('test avatar');
            }
        ));

        /*it('should set $scope.user to the default values when $userDetails is an empty object',
            function () {
                TopLevelMenuDirective({}).link($scope, {}, {});

                expect($scope.user.name).toBe('KoBoForm User');
                expect($scope.user.avatar).toBe('/img/avatars/example-photo.jpg');
        });

        it('should set $scope.user to the default values when $userDetails is null',
            function () {
                TopLevelMenuDirective(null).link($scope, {}, {});

                expect($scope.user.name).toBe('KoBoForm User');
                expect($scope.user.avatar).toBe('/img/avatars/example-photo.jpg');
        });

        it('should read section information from the config service',
            function (){
                TopLevelMenuDirective(
                    null, 
                    {
                        sections: function () { return 'test sections'; }
                    })
                .link($scope, {},{});

                expect($scope.sections).toBe('test sections');
            })*/
    });
 
});