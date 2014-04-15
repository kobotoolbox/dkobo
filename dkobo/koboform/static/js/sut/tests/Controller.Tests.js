/*global describe*/
/*global it */
/*global expect*/
/*global inject*/
/*global sinon*/
/*global beforeEach*/
/*global $*/
'use strict';

describe ('Controllers', function () {
    var hello = {hello: 'world'},
        $rs, $scope,
        $resource = function () {
                        return resourceStub;
                    },
        miscServiceStub = function () {this.changeFileUploaderSuccess = sinon.spy();},
        resourceStub,
        __original_survey_app_create_method;


    beforeEach(function () {
        __original_survey_app_create_method = SurveyApp.create;
        SurveyApp.create = sinon.stub().returns({render: function () {}});
    });

    afterEach(function () {
        SurveyApp.create = __original_survey_app_create_method;
    });

    beforeEach(function () {
        window.$ = sinon.stub();
        $.withArgs(window).returns({bind: sinon.stub(), unbind: sinon.stub()});
        $.withArgs('section.form-builder').returns({get: sinon.stub()});
    });

    function initializeController($controller, name, $rootScope) {
        $rs = $rootScope;
        $scope = $rootScope;

        $controller(name + 'Controller', {
            $rootScope: $rs,
            $scope: $scope,
            $resource: $resource,
            $routeParams: hello,
            $cookies: {csrftoken: 'test token'},
            $miscUtils: new miscServiceStub(),
            $routeTo: sinon.stubObject(RouteToService),
            $restApi: {
                create_question_api: function () { return resourceStub; },
                createSurveyDraftApi: function () { return resourceStub; }
            }
        });
    }

    describe ('Forms Controller', function () {
        beforeEach(function () {
            resourceStub = {
                    query: function (fn) { fn(hello); }
                };
        });
        it('should initialize $rootScope and $scope correctly', inject(function ($controller, $rootScope) {
            initializeController($controller, 'Forms', $rootScope);

            expect($rs.canAddNew).toBe(true);
            expect($rs.activeTab).toBe('Forms');

            expect($scope.infoListItems).toBe(hello);
        }));

        describe('$scope.deleteSurvey', function () {
            it('should delete survey when user confirms deletion', inject(function ($controller, $rootScope) {
                var confirmStub = sinon.stub(),
                    deleteSpy = sinon.spy();

                miscServiceStub = function () {
                    this.confirm = confirmStub;
                    this.changeFileUploaderSuccess = sinon.spy();
                };
                confirmStub.returns(true);

                initializeController($controller, 'Forms', $rootScope);

                $scope.deleteSurvey({ id:0, $delete: deleteSpy });

                expect(confirmStub).toHaveBeenCalledOnce();
                expect(deleteSpy).toHaveBeenCalledOnce();
            }));

            it('should not delete survey when user cancels deletion', inject(function ($controller, $rootScope) {
                var confirmStub = sinon.stub(),
                    deleteSpy = sinon.spy();

                miscServiceStub = function () {
                    this.confirm = confirmStub;
                    this.changeFileUploaderSuccess = sinon.spy();
                };
                confirmStub.returns(false);

                initializeController($controller, 'Forms', $rootScope);

                $scope.deleteSurvey({ id:0, $delete: deleteSpy });

                expect(confirmStub).toHaveBeenCalledOnce();
                expect(deleteSpy).not.toHaveBeenCalled();
            }));
        });

        describe('$scope.$watch("infoListItems")', function () {
            it('should set additionalClasses = content-centered when infoListItems is empty', inject (function ($controller, $rootScope) {
                initializeController($controller, 'Forms', $rootScope);

                $rs.infoListItems = [];
                $rs.$apply();

                expect($rs.additionalClasses).toBe('content--centered');
            }));

            it('should set additionalClasses = "" when infoListItems contains elements', inject (function ($controller, $rootScope) {
                initializeController($controller, 'Forms', $rootScope);

                $rs.infoListItems = [1];
                $rs.$apply();

                expect($rs.additionalClasses).toBe('');
            }));
        })
    });

    describe('Assets Controller', function () {
        beforeEach(function () {
            resourceStub = {
                list: function () { $rs.info_list_items = hello;}
            };
        });
        it('should initialize $scope and $rootScope correctly', inject(function ($controller, $rootScope) {
            initializeController($controller, 'Assets', $rootScope);

            expect($rs.canAddNew).toBe(true);
            expect($rs.activeTab).toBe('Question Library');

            expect($scope.info_list_items).toBe(hello);
        }));

        describe('$scope.toggle_response_list', function () {
            it('shows responses when they are hidden', inject(function ($controller, $rootScope) {
                initializeController($controller, 'Assets', $rootScope);
                var item = {
                    type: 'select_one',
                    meta: {
                        show_responses: false
                    }
                }

                $rootScope.toggle_response_list(item);

                expect(item.meta.question_type_class).toBe('question__type question__type--expanded');
                expect(item.meta.question_type_icon_class).toBe('question__type-icon question__type--expanded-icon');
                expect(item.meta.question_type_icon).toBe('fa fa-caret-down');
                expect(item.meta.show_responses).toBe(true);
            }));
            it('hides responses when they are visible', inject(function ($controller, $rootScope) {
                initializeController($controller, 'Assets', $rootScope);
                var item = {
                    type: 'select_one',
                    meta: {
                        show_responses: true
                    }
                }

                $rootScope.toggle_response_list(item);

                expect(item.meta.show_responses).toBe(false);
                expect(item.meta.question_type_class).toBe('question__type');
                expect(item.meta.question_type_icon).toBe('fa fa-caret-right');
                expect(item.meta.question_type_icon_class).toBe('question__type-icon');
            }));
        });

        describe('scope.toggle_selected', function () {
            var _items;
            beforeEach(inject(function ($controller, $rootScope) {
                _items = [
                    { label: 'Currently, what is your main priority or concern?', type: 'Select Many', meta: {} },
                    { label: 'If you have a dispute in your community, to whom do you take it first?', type: 'Select Many', meta: {} },
                    { label: 'Why do you take it first to that person or institution?', type: 'Select Many', meta: {} }
                ];

                resourceStub = {
                    list: function () { $rs.info_list_items = _items;}
                };

                initializeController($controller, 'Assets', $rootScope);
            }));

            it('selects a deselected question', function () {
                $rs.toggle_selected(_items[1], {ctrlKey: false});

                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[1].meta.question_class).toBe('questions__question questions__question--selected');
            });
            it('deselects a selected question', function () {
                _items[1].meta.is_selected = true;
                $rs.toggle_selected(_items[1], {ctrlKey: false});

                expect(_items[1].meta.is_selected).toBeFalsy();
                expect(_items[1].meta.question_class).toBe('questions__question');
            });
            it('deselects all previously selected questions', function () {
                _items[0].meta.is_selected = true;
                _items[2].meta.is_selected = true;
                $rs.toggle_selected(_items[1], {ctrlKey: false});

                expect(_items[0].meta.question_class).toBe('questions__question');
                expect(_items[0].meta.is_selected).toBeFalsy();
                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[2].meta.question_class).toBe('questions__question');
                expect(_items[2].meta.is_selected).toBeFalsy();
            });
            it('keeps previously selected questions when ctrl is pressed', function () {
                _items[0].meta.is_selected = true;
                _items[2].meta.is_selected = true;
                $rs.toggle_selected(_items[1], {ctrlKey: true});

                expect(_items[0].meta.is_selected).toBeTruthy();
                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[2].meta.is_selected).toBeTruthy();
            });
            it('deselects all questions except clicked question when multiple questions selected, current question selected and ctrl isnt pressed', function () {
                _items[0].meta.is_selected = true;
                _items[1].meta.is_selected = true;
                _items[2].meta.is_selected = true;
                $rs.toggle_selected(_items[1], {ctrlKey: false});

                expect(_items[0].meta.is_selected).toBeFalsy();
                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[2].meta.is_selected).toBeFalsy();
            });
            it('deselects a selected question when multiple questions selected and ctrl is pressed', function () {
                _items[0].meta.is_selected = true;
                _items[1].meta.is_selected = true;
                _items[2].meta.is_selected = true;
                $rs.toggle_selected(_items[1], {ctrlKey: true});

                expect(_items[0].meta.is_selected).toBeTruthy();
                expect(_items[1].meta.is_selected).toBeFalsy();
                expect(_items[2].meta.is_selected).toBeTruthy();
            });
            it('sets select_all switch when all questions selected', function () {
                _items[0].meta.is_selected = true;
                _items[2].meta.is_selected = true;
                $rs.toggle_selected(_items[1], {ctrlKey: true});

                expect($rs.select_all).toBeTruthy();
            })
            it('clears select_all switch when not all questions selected', function () {
                _items[0].meta.is_selected = true;
                _items[1].meta.is_selected = true;
                _items[2].meta.is_selected = true;
                $rs.select_all = true;
                $rs.toggle_selected(_items[1], {ctrlKey: true});

                expect($rs.select_all).toBeFalsy();
            })
        });

        describe('scope.watch select_all', function () {
            var _items;

            beforeEach(function () {
                _items = [
                    { label: 'Currently, what is your main priority or concern?', type: 'Select Many', meta: {} },
                    { label: 'If you have a dispute in your community, to whom do you take it first?', type: 'Select Many', meta: {} },
                    { label: 'Why do you take it first to that person or institution?', type: 'Select Many', meta: {} }
                ];

                resourceStub = {
                    list: function () { $rs.info_list_items = _items;}
                };
            });

            it('sets selected properties to selected on all objects when select_all is true', inject(function ($controller, $rootScope) {
                initializeController($controller, 'Assets', $rootScope);

                $rootScope.select_all = true;
                $rootScope.$apply();


                expect(_items[0].meta.is_selected).toBeTruthy();
                expect(_items[0].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[1].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[2].meta.is_selected).toBeTruthy();
                expect(_items[2].meta.question_class).toBe('questions__question questions__question--selected');
            }));

            it('sets selected properties to deselected on all objects when select_all is false', inject(function ($controller, $rootScope) {
                initializeController($controller, 'Assets', $rootScope);

                $rootScope.select_all = false;
                $rootScope.$apply();


                expect(_items[0].meta.is_selected).toBeFalsy();
                expect(_items[0].meta.question_class).toBe('questions__question');
                expect(_items[1].meta.is_selected).toBeFalsy();
                expect(_items[1].meta.question_class).toBe('questions__question');
                expect(_items[2].meta.is_selected).toBeFalsy();
                expect(_items[2].meta.question_class).toBe('questions__question');
            }));

            it('no-ops when select_all is null', inject(function ($controller, $rootScope) {
                initializeController($controller, 'Assets', $rootScope);

                $rootScope.select_all = true;
                $rootScope.$apply();

                $rootScope.select_all = null;
                $rootScope.$apply();


                expect(_items[0].meta.is_selected).toBeTruthy();
                expect(_items[0].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[1].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[2].meta.is_selected).toBeTruthy();
                expect(_items[2].meta.question_class).toBe('questions__question questions__question--selected');
            }));
        });
    });

    describe('Header Controller', function () {
        beforeEach(function () {
            miscServiceStub = function () {
                this.bootstrapFileUploader = function () {};
                this.changeFileUploaderSuccess = sinon.spy();
            };
        });


        it('should initialize $scope and $rootScope correctly', inject(function ($controller, $rootScope) {
            initializeController($controller, 'Header', $rootScope);

            expect($scope.pageIconColor).toBe('teal');
            expect($scope.pageTitle).toBe('Forms');
            expect($scope.pageIcon).toBe('fa-file-text-o');
            expect($scope.topLevelMenuActive).toBe('');
            expect($rs.activeTab).toBe('Forms');
        }));

        describe('$scope.toggleTopMenu', function () {
            it('should set the value of $scope.topLevelMenuActive to "is-active" when its value is an empty string',
                inject(function ($controller, $rootScope) {
                    initializeController($controller, 'Header', $rootScope);

                    $rs.topLevelMenuActive = '';
                    $scope.toggleTopMenu();

                    expect($rs.topLevelMenuActive).toBe('is-active');
                })
            );

            it('should set the value of $scope.topLevelMenuActive to an empty string when its value is "is-active"',
                inject(function ($controller, $rootScope) {
                    initializeController($controller, 'Header', $rootScope);

                    $rs.topLevelMenuActive = 'is-active';
                    $scope.toggleTopMenu();

                    expect($rs.topLevelMenuActive).toBe('');
                })
            );
        });
    });

    describe('Builder Controller', function () {

        it('should initialize $scope and $rootScope correctly', inject(function ($controller, $rootScope) {
            initializeController($controller, 'Builder', $rootScope);

            expect($rs.activeTab).toBe('Forms');
            expect($scope.routeParams).toBe(hello);
        }));

        describe('Location Change Confirmation', function () {
            it('Should change location when user accepts confirmation', inject(function ($controller, $rootScope) {
                var confirmStub = sinon.stub();

                miscServiceStub = function () {
                    this.confirm = confirmStub;
                    this.changeFileUploaderSuccess = sinon.spy();
                };
                confirmStub.returns(true);

                initializeController($controller, 'Builder', $rootScope);
                $rootScope.deregisterLocationChangeStart = sinon.spy();

                $rs.$broadcast('$locationChangeStart');
                expect(confirmStub).toHaveBeenCalledOnce();
                expect(confirmStub).toHaveBeenCalledWith('Are you sure you want to leave? you will lose any unsaved changes.');
                expect($rootScope.deregisterLocationChangeStart).toHaveBeenCalledOnce();

                miscServiceStub = function (){};
            }));

            it('Should keep location when user rejects confirmation', inject(function ($controller, $rootScope) {
                var confirmStub = sinon.stub(),
                    preventDefaultSpy = sinon.spy();

                miscServiceStub = function () {
                    this.confirm = confirmStub;
                    this.preventDefault = preventDefaultSpy;
                    this.changeFileUploaderSuccess = sinon.spy();
                };

                confirmStub.returns(false);

                initializeController($controller, 'Builder', $rootScope);

                $rs.$broadcast('$locationChangeStart');

                expect(confirmStub).toHaveBeenCalledOnce();
                expect(confirmStub).toHaveBeenCalledWith('Are you sure you want to leave? you will lose any unsaved changes.');
                expect(preventDefaultSpy).toHaveBeenCalledOnce();

                miscServiceStub = function () {};
            }));

        });

        describe('$scope.add_row_to_question_library', function () {
            it('posts a survey object to the server', inject(function ($controller, $rootScope) {
                var survey_stub = {
                        rows: {
                            add: sinon.spy()
                        },
                        toCSV: sinon.stub()
                    },
                    survey_factory_stub = sinon.stub(XLF.Survey, 'create');

                survey_factory_stub.returns(survey_stub);
                survey_stub.toCSV.returns('test survey');

                resourceStub = {
                    save: sinon.spy()
                };

                initializeController($controller, 'Builder', $rootScope);

                $rootScope.add_row_to_question_library('test row')
                expect(resourceStub.save).toHaveBeenCalledWith({body: 'test survey', asset_type: 'question'});
                expect(survey_stub.rows.add).toHaveBeenCalledWith('test row')
            }));
        });
    });

    describe('Import Controller', function () {
        it('should initialize $scope and $rootScope correctly', inject(function ($controller, $rootScope) {
            initializeController($controller, 'Import', $rootScope);

            expect($scope.csrfToken).toBe('test token');
            expect($rs.canAddNew).toBe(false);
            expect($rs.activeTab).toBe('Import CSV');
        }));
    });
});