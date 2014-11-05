/* exported restApiFactory */
/* global dkobo_xlform */
'use strict';



kobo.factory('$restApi', function ($resource, $timeout, $cacheFactory, $rootScope, $http) {
    var cache = $cacheFactory('rest api');

    function createApi(url, opts) {
        opts.customMethods = _.extend({
            update: { method: 'PATCH' }
        }, opts.customMethods);

        var assetName = /\/api\/(\w+)\/:id/.exec(url)[1];
        if (opts.paged === true) {
            // to get around angular's resource trailing slash idiocy...
            var pagingApi = $resource('/api/' + assetName + '?page=:nextPage', { id: '@id' }, opts.customMethods);
        }

        var api = $resource(url, { id: '@id' }, opts.customMethods);
        var actions = {};
        var nextPage = 1;

        function makeAction(action) {
            return function (item) {
                return api[action](item);
            }
        }

        for (var action in opts.customMethods) {
            if (opts.customMethods.hasOwnProperty(action)) {
                actions[action] = makeAction(action);
            }
        }

        opts.saveCallback = opts.saveCallback || function () {};
        opts.updateCallback = opts.updateCallback || function () {};
        opts.listCallback = opts.listCallback || function () {};
        opts.removeCallback = opts.removeCallback || function () {};

        var isListing = false;
        var listFn = opts.paged === true ?
            function () {
                var data = cache.get('list:' + assetName),
                    _this = this;

                if (!data) {
                    nextPage = 1;
                }
                if (isListing) {
                    return data.$promise;
                }
                if(nextPage) {
                    isListing = true
                    data = pagingApi.get({ nextPage: nextPage}, function () {
                        if (nextPage === 1) {
                            _this.items = data.results;
                        } else {
                            _this.items = _this.items.concat(data.results);
                        }
                        nextPage = data.next && /page=(\d+)/g.exec(data.next)[1];
                        arguments[0] = _this.items;
                        opts.listCallback.apply(_this, arguments);
                        $rootScope.$broadcast('list:' + assetName);
                        isListing = false;
                    });
                    cache.put('list:' + assetName, data);
                    return data.$promise
                }
                return data.$promise;
            }
        :
            function () {
                var data = cache.get('list:' + assetName),
                    _this = this;
                if(!data) {
                    data = api.query(function () {
                        _this.items = data;
                        opts.listCallback.apply(_this, arguments);
                        $rootScope.$broadcast('list:' + assetName);
                    });
                    cache.put('list:' + assetName, data);
                }

                return data.$promise
            };

        var publicApi = _.extend({
            list: listFn,
            remove: function (item) {

                var callback = function () {
                    var data = cache.remove('list:' + assetName);

                    _this.items = _.filter(_this.items, function (item) {
                        return !item.meta.isSelected
                    });
                    opts.removeCallback.apply(_this, arguments);
                    $rootScope.$broadcast('remove:' + assetName);
                    nextPage = 1;
                    _this.list();
                };

                var _this = this,
                    ids;
                if (item instanceof Array) {
                    ids = [];
                    _.each(item, function (item) {
                        ids.push(item.id);
                    });
                    return $http.post('/api/bulk_delete/' + assetName, ids).success(callback)
                } else {
                    ids = {id: item.id};
                    return api.remove(ids, callback).$promise;
                }

            },
            save: function (item) {
                var data = cache.remove('list:' + assetName),
                    _this = this;
                if (item.id) {
                    return api.update(item, function () {
                        opts.updateCallback.apply(_this, arguments);
                        $rootScope.$broadcast('update:' + assetName);
                    }).$promise;
                } else {
                    return api.save(item, opts.saveCallback.bind(this)).$promise;
                    $rootScope.$broadcast('add:' + assetName);
                }
                $rootScope.$broadcast('save:' + assetName);
            },
            get: function (args) {
                return api.get(args, function () {
                    $rootScope.$broadcast('get:' + assetName);
                }).$promise;
            }
        }, actions);
        $rootScope.$on('reload:' + assetName, publicApi.list.bind(publicApi));
        return publicApi;
    }

    return {
        createSurveyDraftsApi: function () {
            return createApi('/api/survey_drafts/:id', {
                customMethods: { publish: { method: 'POST', url: '/api/survey_drafts/:id/publish' } }
            })
        },
        createQuestionsApi: function ($scope, id) {
            return createApi('/api/library_assets/:id', {
                listCallback: function () {
                    initialize_questions(this.items);
                },
                saveCallback: function () {
                    cache.remove('list:tags');
                    $rootScope.$broadcast('reload:tags');
                },
                updateCallback: function () {
                    cache.remove('list:tags');
                    $rootScope.$broadcast('reload:tags');
                },
                removeCallback: function () {
                    cache.remove('list:tags');
                    $rootScope.$broadcast('reload:tags');
                },
                paged: true
            });

            function initialize_questions(info_list_items) {
                function create_survey(item) {
                    item.backbone_model = dkobo_xlform.model.Survey.load(item.body);
                }

                function set_defaults(item) {
                    if (!item.meta) {
                        item.meta = {
                            show_responses: false,
                            is_selected: false,
                            question_class: 'questions__question',
                            question_type_class: 'question__type',
                            question_type_icon: 'fa fa-caret-right fa-fw',
                            question_type_icon_class: 'question__type-icon'
                        };
                    }
                }

                function get_props_from_row(item) {
                    var row = item.backbone_model.rows.at(0);

                    if(row) {
                        item.type = row.get("type").get("typeId");

                        item.label = item.type === 'calculate' ? row.getValue('calculation') : row.getValue('label');

                        var list = row.getList();
                        if (list) {
                            item.responses = list.options.map(function(option) {
                                return option.get("label");
                            });
                        }
                        results.push(row);

                        // for demo purposes
                        row.date = new Date().setDate(new Date().getDate() - i);
                    }
                }

                var results = [];
                var i = 0;

                for (i = 0; i < info_list_items.length; i++) {
                    set_defaults(info_list_items[i]);
                }

                i = 0;

                function timed_execution(item) {
                    return $timeout(function () {
                        create_survey(item);
                    }, 10).then(function () {
                        get_props_from_row(item);
                    }).then(function () {
                        i++;
                        if (i < info_list_items.length) {
                            timed_execution(info_list_items[i]);
                        }
                    });
                }

                if (info_list_items.length > 0) {
                    timed_execution(info_list_items[i]);
                }
                return info_list_items;
            }
        },
        createTagsApi: function () {
            var metas = {};

            function initialize_items(items) {
                _.each(items, function (item) {
                    if (!item.meta) {
                        if (metas[item.id]) {
                            item.meta = metas[item.id];
                        } else {
                            item.meta = metas[item.id] = {};
                        }
                    }
                });
            }

            return createApi('/api/tags/:id', {
                listCallback: function () {
                    initialize_items(this.items);
                },
                updateCallback: function () {
                    cache.remove('list:library_assets');
                    $rootScope.$broadcast('reload:library_assets');

                },
                saveCallback: function (tag) {
                    tag.meta = {};
                    this.items.push(tag);
                }
            });
        }
    };
});