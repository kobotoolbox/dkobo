/*global describe*/
/*global it */
/*global expect*/
/*global inject*/
/*global beforeEach*/
/*global module*/
'use strict';

describe ('Directives', function () {
    beforeEach(module('dkobo'));
    beforeEach(module('templates/TopLevelMenu.Template.html'));
    beforeEach(module('templates/InfoList.Template.html'));

    function mockUserDetails(mockObject) {
        return module(function ($provide) {
            $provide.provider('$userDetails', function () {
                this.$get = function () {
                    return mockObject;
                };
            });
        });
    }

    function buildDirective($compile, $rootScope, element) {
        element = $compile(element)($rootScope);
        $rootScope.$apply();
        return element.isolateScope();
    }

    describe ('Top level menu Directive', function () {
        function buildTopLevelMenuDirective($compile, $rootScope) {
            return buildDirective($compile, $rootScope, '<div top-level-menu></div>');
        }

        describe('Mocked $userDetails', function () {
            beforeEach(mockUserDetails({
                name: 'test name',
                gravatar: 'test avatar'
            }));

            it('should set $rootScope.user to values passed by $userDetails',
                inject(function($compile, $rootScope) {
                    var isolateScope = buildTopLevelMenuDirective($compile, $rootScope);

                    expect(isolateScope.user.name).toBe('test name');
                    expect(isolateScope.user.avatar).toBe('test avatar');
                }
            ));
        });

        describe('empty $userDetails', function() {
            beforeEach(mockUserDetails({}));
            it('should set $rootScope.user to the default values when $userDetails is an empty object',
                inject(function ($compile, $rootScope) {
                    var isolateScope = buildTopLevelMenuDirective($compile, $rootScope);

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
                    var isolateScope = buildTopLevelMenuDirective($compile, $rootScope);

                    expect(isolateScope.user.name).toBe('KoBoForm User');
                    expect(isolateScope.user.avatar).toBe('/img/avatars/example-photo.jpg');
                })
            );

            it('should read section information from the config service',
                inject(function ($compile, $rootScope) {
                    var isolateScope = buildTopLevelMenuDirective($compile, $rootScope);

                    expect(isolateScope.sections).toBe(mockConfig);
                })
            );
        });

    });

    describe('InfoList Directive', function () {
        function buildInfoListDirective($compile, $rootScope, canAddNew, linkTo) {
            return buildDirective(
                $compile,
                $rootScope,
                '<div info-list items="items" can-add-new="' + canAddNew + '" name="test" link-to="' + linkTo + '"></div>'
            );
        }

        it('should initialize the scope correctly',
            inject(function ($compile, $rootScope) {
                $rootScope.items = [{}];

                buildInfoListDirective($compile, $rootScope, true);

                expect($rootScope.canAddNew).toBe(true);
                expect($rootScope.activeTab).toBe('test');
            })
        );

        it('should initialize the scope with canAddNew === false when "false" is passed on directives attribute',
            inject(function ($compile, $rootScope) {
                $rootScope.items = [{}];

                buildInfoListDirective($compile, $rootScope, false);

                expect($rootScope.canAddNew).toBe(false);
                expect($rootScope.activeTab).toBe('test');
            })
        );

        describe('getHashLink', function () {
            it('should return a URI when linkTo is provided',
                inject(function ($compile, $rootScope){
                    var isolateScope = buildInfoListDirective($compile, $rootScope, false, 'test');

                    expect(isolateScope.getHashLink({id: 1})).toBe('/test/1');
                })
            );

            it('should return a URI when linkTo is provided',
                inject(function ($compile, $rootScope){
                    var isolateScope = buildInfoListDirective($compile, $rootScope, false, '');

                    expect(isolateScope.getHashLink({id: 1})).toBe('');
                })
            );
        });
    });

});