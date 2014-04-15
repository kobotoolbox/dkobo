/*global describe*/
/*global it */
/*global expect*/
/*global inject*/
/*global sinon*/
/*global beforeEach*/
/*global afterEach*/
/*global $*/
/*global SurveyApp*/
/*global RouteToService*/
/*global XLF*/
'use strict';

describe ('Controllers', function () {
    var hello = {hello: 'world'},
        $rs, $scope,
        $resource = function () {
                        return resourceStub;
                    },
        miscServiceStub = function () {
            this.changeFileUploaderSuccess = sinon.spy();
            this.confirm = _confirmStub;
        },
        resourceStub,
        _confirmStub,
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
        var _confirmStub, _deleteSpy;

        beforeEach(inject(function ($controller, $rootScope) {
            resourceStub = {
                query: function (fn) { fn(hello); }
            };

            _confirmStub = sinon.stub();
            _deleteSpy = sinon.spy();

            miscServiceStub = function () {
                this.confirm = _confirmStub;
                this.changeFileUploaderSuccess = sinon.spy();
            };

            initializeController($controller, 'Forms', $rootScope);
        }));

        it('should initialize $rootScope and $scope correctly', function () {
            expect($rs.canAddNew).toBe(true);
            expect($rs.activeTab).toBe('Forms');

            expect($scope.infoListItems).toBe(hello);
        });

        describe('$scope.deleteSurvey', function () {
            it('should delete survey when user confirms deletion', function () {
                _confirmStub.returns(true);

                $scope.deleteSurvey({ id:0, $delete: _deleteSpy });

                expect(_confirmStub).toHaveBeenCalledOnce();
                expect(_deleteSpy).toHaveBeenCalledOnce();
            });

            it('should not delete survey when user cancels deletion', function () {
                _confirmStub.returns(false);

                $scope.deleteSurvey({ id:0, $delete: _deleteSpy });

                expect(_confirmStub).toHaveBeenCalledOnce();
                expect(_deleteSpy).not.toHaveBeenCalled();
            });
        });

        describe('$scope.$watch("infoListItems")', function () {
            it('should set additionalClasses = content-centered when infoListItems is empty', function () {
                $rs.infoListItems = [];
                $rs.$apply();

                expect($rs.additionalClasses).toBe('content--centered');
            });

            it('should set additionalClasses = "" when infoListItems contains elements', function () {
                $rs.infoListItems = [1];
                $rs.$apply();

                expect($rs.additionalClasses).toBe('');
            });
        });
    });

    describe('Assets Controller', function () {
        var _items;

        beforeEach(inject(function ($controller, $rootScope) {
            _items = [
                { id: 1, label: 'Currently, what is your main priority or concern?', type: 'Select Many', meta: {} },
                { id: 2, label: 'If you have a dispute in your community, to whom do you take it first?', type: 'Select Many', meta: {} },
                { id: 3, label: 'Why do you take it first to that person or institution?', type: 'Select Many', meta: {} }
            ];

            _confirmStub = sinon.stub();

            miscServiceStub = function () {
                this.changeFileUploaderSuccess = sinon.spy();
                this.confirm = _confirmStub;
            }

            resourceStub = {
                list: function () { $rs.info_list_items = _items;},
                remove: sinon.spy()
            };

            initializeController($controller, 'Assets', $rootScope);
        }));

        it('should initialize $scope and $rootScope correctly', inject(function ($controller, $rootScope) {
            initializeController($controller, 'Assets', $rootScope);

            expect($rs.canAddNew).toBe(true);
            expect($rs.activeTab).toBe('Question Library');

            expect($scope.info_list_items).toBe(_items);
        }));

        describe('$scope.toggle_response_list', function () {
            it('shows responses when they are hidden', function () {
                var item = {
                    type: 'select_one',
                    meta: {
                        show_responses: false
                    }
                };

                $rs.toggle_response_list(item);

                expect(item.meta.question_type_class).toBe('question__type question__type--expanded');
                expect(item.meta.question_type_icon_class).toBe('question__type-icon question__type--expanded-icon');
                expect(item.meta.question_type_icon).toBe('fa fa-caret-down');
                expect(item.meta.show_responses).toBe(true);
            });
            it('hides responses when they are visible', function () {
                var item = {
                    type: 'select_one',
                    meta: {
                        show_responses: true
                    }
                };

                $rs.toggle_response_list(item);

                expect(item.meta.show_responses).toBe(false);
                expect(item.meta.question_type_class).toBe('question__type');
                expect(item.meta.question_type_icon).toBe('fa fa-caret-right');
                expect(item.meta.question_type_icon_class).toBe('question__type-icon');
            });
        });

        describe('scope.toggle_selected', function () {

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
            });
            it('clears select_all switch when not all questions selected', function () {
                _items[0].meta.is_selected = true;
                _items[1].meta.is_selected = true;
                _items[2].meta.is_selected = true;
                $rs.select_all = true;
                $rs.toggle_selected(_items[1], {ctrlKey: true});

                expect($rs.select_all).toBeFalsy();
            });
        });

        describe('scope.watch select_all', function () {
            it('sets selected properties to selected on all objects when select_all is true', function () {

                $rs.select_all = true;
                $rs.$apply();


                expect(_items[0].meta.is_selected).toBeTruthy();
                expect(_items[0].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[1].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[2].meta.is_selected).toBeTruthy();
                expect(_items[2].meta.question_class).toBe('questions__question questions__question--selected');
            });

            it('sets selected properties to deselected on all objects when select_all is false', function () {

                $rs.select_all = false;
                $rs.$apply();


                expect(_items[0].meta.is_selected).toBeFalsy();
                expect(_items[0].meta.question_class).toBe('questions__question');
                expect(_items[1].meta.is_selected).toBeFalsy();
                expect(_items[1].meta.question_class).toBe('questions__question');
                expect(_items[2].meta.is_selected).toBeFalsy();
                expect(_items[2].meta.question_class).toBe('questions__question');
            });

            it('no-ops when select_all is null', function () {

                $rs.select_all = true;
                $rs.$apply();

                $rs.select_all = null;
                $rs.$apply();


                expect(_items[0].meta.is_selected).toBeTruthy();
                expect(_items[0].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[1].meta.is_selected).toBeTruthy();
                expect(_items[1].meta.question_class).toBe('questions__question questions__question--selected');
                expect(_items[2].meta.is_selected).toBeTruthy();
                expect(_items[2].meta.question_class).toBe('questions__question questions__question--selected');
            });
        });

        describe("$scope.delete_selected", function () {
            it("deletes all selected items", function () {
                _items[1].meta.is_selected = true;

                _confirmStub.returns(true);
                $scope.delete_selected();

                expect(resourceStub.remove).toHaveBeenCalledWith({id: 2});

                expect($rs.info_list_items.length).toBe(2);
                expect($rs.info_list_items[0].id).toBe(1);
                expect($rs.info_list_items[1].id).toBe(3);
            });

            it("no ops when confirmation returns false", function () {
                _items[1].meta.is_selected = true;

                _confirmStub.returns(false);
                $scope.delete_selected();

                expect($rs.info_list_items.length).toBe(3);
                expect($rs.info_list_items[0].id).toBe(1);
                expect($rs.info_list_items[1].id).toBe(2);
                expect($rs.info_list_items[2].id).toBe(3);
            });
        });
    });

    describe('Header Controller', function () {
        beforeEach(inject(function ($controller, $rootScope) {
            miscServiceStub = function () {
                this.bootstrapFileUploader = function () {};
                this.changeFileUploaderSuccess = sinon.spy();
            };
            initializeController($controller, 'Header', $rootScope);
        }));


        it('should initialize $scope and $rootScope correctly', function () {
            expect($scope.pageIconColor).toBe('teal');
            expect($scope.pageTitle).toBe('Forms');
            expect($scope.pageIcon).toBe('fa-file-text-o');
            expect($scope.topLevelMenuActive).toBe('');
            expect($rs.activeTab).toBe('Forms');
        });

        describe('$scope.toggleTopMenu', function () {
            it('should set the value of $scope.topLevelMenuActive to "is-active" when its value is an empty string', function () {
                $rs.topLevelMenuActive = '';
                $scope.toggleTopMenu();

                expect($rs.topLevelMenuActive).toBe('is-active');
            });

            it('should set the value of $scope.topLevelMenuActive to an empty string when its value is "is-active"', function () {
                $rs.topLevelMenuActive = 'is-active';
                $scope.toggleTopMenu();

                expect($rs.topLevelMenuActive).toBe('');
            });
        });
    });

    describe('Builder Controller', function () {
        var _confirmStub, _preventDefaultSpy;

        beforeEach(inject(function ($controller, $rootScope) {
            _confirmStub = sinon.stub();
            _preventDefaultSpy = sinon.spy();

            miscServiceStub = function () {
                this.confirm = _confirmStub;
                this.preventDefault = _preventDefaultSpy;
                this.changeFileUploaderSuccess = sinon.spy();
            };
            initializeController($controller, 'Builder', $rootScope);
        }));

        afterEach(function () {
            miscServiceStub = function (){};
        });

        it('should initialize $scope and $rootScope correctly', function () {
            expect($rs.activeTab).toBe('Forms');
            expect($scope.routeParams).toBe(hello);
        });

        describe('Location Change Confirmation', function () {
            it('Should change location when user accepts confirmation', function () {
                _confirmStub.returns(true);

                $rs.deregisterLocationChangeStart = sinon.spy();

                $rs.$broadcast('$locationChangeStart');
                expect(_confirmStub).toHaveBeenCalledOnce();
                expect(_confirmStub).toHaveBeenCalledWith('Are you sure you want to leave? you will lose any unsaved changes.');
                expect($rs.deregisterLocationChangeStart).toHaveBeenCalledOnce();
            });

            it('Should keep location when user rejects confirmation', function () {
                _confirmStub.returns(false);

                $rs.$broadcast('$locationChangeStart');

                expect(_confirmStub).toHaveBeenCalledOnce();
                expect(_confirmStub).toHaveBeenCalledWith('Are you sure you want to leave? you will lose any unsaved changes.');
                expect(_preventDefaultSpy).toHaveBeenCalledOnce();
            });

        });

        describe('$scope.add_row_to_question_library', function () {
            it('posts a survey object to the server', function () {
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

                $rs.add_row_to_question_library('test row');
                expect(resourceStub.save).toHaveBeenCalledWith({body: 'test survey', asset_type: 'question'});
                expect(survey_stub.rows.add).toHaveBeenCalledWith('test row');
            });
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