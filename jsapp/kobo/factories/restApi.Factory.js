/* exported restApiFactory */
/* global dkobo_xlform */
'use strict';



kobo.factory('$restApi', function ($resource, $timeout, $cacheFactory, $rootScope) {
    var cache = $cacheFactory('rest api');
    function createApi(url, opts) {
        opts.customMethods = _.extend({
            update: { method: 'PATCH' }
        }, opts.customMethods);

        var api = $resource(url, { id: '@id' }, opts.customMethods);

        var actions = {};

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


        var publicApi = _.extend({
            list: function () {
                var data = cache.get('list:' + url);
                if(!data) {
                    data = api.query(opts.listCallback.bind(this));
                    cache.put('list:' + url, data);
                }
                this.items = data;
                return data.$promise
            },
            remove: function (item) {
                var that = this;
                return api.remove({id: item.id}, function () {
                    var data = cache.remove('list:' + url);
                    var index = _.indexOf(that.items, _.filter(that.items, function (_item) {
                        return _item.id === item.id;
                    })[0]);
                    that.items.splice(index, 1);
                }).$promise;
            },
            save: function (item) {
                var data = cache.remove('list:' + url);
                if (item.id) {
                    return api.update(item, opts.updateCallback.bind(this)).$promise;
                } else {
                    return api.save(item, opts.saveCallback.bind(this)).$promise;
                }
            },
            get: function (args) {
                return api.get(args).$promise;
            }
        }, actions);
        $rootScope.$on('reload:' + url, publicApi.list.bind(publicApi));
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
                    $rootScope.$broadcast('reload:api/tags/:id');
                }
            });

            function initialize_questions(info_list_items) {
                function create_survey(item) {
                    item.backbone_model = dkobo_xlform.model.Survey.load(item.body);
                }

                function set_defaults(item) {
                    item.meta = {
                        show_responses: false,
                        is_selected: false,
                        question_class: 'questions__question',
                        question_type_class: 'question__type',
                        question_type_icon: 'fa fa-caret-right fa-fw',
                        question_type_icon_class: 'question__type-icon'
                    };
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
            function initialize_items(items) {
                _.each(items, function (item) {
                    if (!item.meta) {
                        item.meta = {};
                    }
                });
            }

            return createApi('api/tags/:id', {
                listCallback: function () {
                    initialize_items(this.items);
                },
                updateCallback: function () {
                    cache.remove('list:/api/library_assets/:id');
                    $rootScope.$broadcast('reload:/api/library_assets/:id');

                },
                saveCallback: function (tag) {
                    tag.meta = {};
                    this.items.push(tag);
                }
            });
        }
    };
});