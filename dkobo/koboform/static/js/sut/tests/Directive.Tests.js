/*global describe*/
/*global it */
/*global expect*/
/*global inject*/
/*global beforeEach*/
/*global module*/
/*global beforeEach*/
/*global beforeEach*/
/*global beforeEach*/

'use strict';
describe ('Directives', function () {
    beforeEach(module('dkobo'));
    beforeEach(module('templates/TopLevelMenu.Template.html'));

    function mockUserDetails(mockObject) {
        return module(function ($provide) {
            $provide.provider('$userDetails', function () {
                this.$get = function () {
                    return mockObject;
                };
            });
        });
    }

    function buildDirective($compile, $rootScope) {
        var element = '<div top-level-menu></div>';
        element = $compile(element)($rootScope);
        $rootScope.$apply();
        return element.isolateScope();
    }

    describe ('Top level menu Directive', function () {
        describe('Mocked $userDetails', function () {
            beforeEach(mockUserDetails({
                name: 'test name',
                gravatar: 'test avatar'
            }));

            it('should set $rootScope.user to values passed by $userDetails',
                inject(function($compile, $rootScope) {
                    var isolateScope = buildDirective($compile, $rootScope);

                    expect(isolateScope.user.name).toBe('test name');
                    expect(isolateScope.user.avatar).toBe('test avatar');
                }
            ));
        });

        describe('empty $userDetails', function() {
            beforeEach(mockUserDetails({}));
            it('should set $rootScope.user to the default values when $userDetails is an empty object',
                inject(function ($compile, $rootScope) {
                    var isolateScope = buildDirective($compile, $rootScope);

                    expect(isolateScope.user.name).toBe('KoBoForm User');
                    expect(isolateScope.user.avatar).toBe('/img/avatars/example-photo.jpg');
                })
            );
        });

        describe('null $userDetails', function () {
            var mockConfig = [{
                'title': 'test title',
                'icon': 'fa-file-text-o',
                'name': 'test name'
            }];

            beforeEach(mockUserDetails(null));
            beforeEach(module(function ($provide) {
                $provide.provider('$configuration', function () {
                    this.$get = function () {
                        return { sections: function () { return mockConfig; } };
                    };
                });
            }));
            it('should set $rootScope.user to the default values when $userDetails is null',
                inject(function ($compile, $rootScope) {
                    var isolateScope = buildDirective($compile, $rootScope);

                    expect(isolateScope.user.name).toBe('KoBoForm User');
                    expect(isolateScope.user.avatar).toBe('/img/avatars/example-photo.jpg');
                })
            );

            it('should read section information from the config service',
                inject(function ($compile, $rootScope) {
                    var isolateScope = buildDirective($compile, $rootScope);

                    expect(isolateScope.sections).toBe(mockConfig);
                })
            );
        });

    });

});