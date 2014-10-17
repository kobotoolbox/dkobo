/* exported restApiFactory */
/* global dkobo_xlform */
'use strict';

function restApiFactory($rootScope, $resource, $timeout) {
    var lists = {},
        apis = {};


    function initialize_items(items) {
        _.each(items, function (item) {
            if (!item.meta) {
                item.meta = {};
            }
        });
    }
    return {
        createSurveyDraftApi: function (id) {
            if (id === undefined) {
                id = 'new';
            }

            var api = $resource('/api/survey_drafts/:id', { id: '@id' }, {
                update: { method: 'PATCH' },
                publish: { method: 'POST', url: '/api/survey_drafts/:id/publish' }
            });

            return apis.surveyDraft = {
                list: function () {
                    return lists.surveyDrafts ? lists.surveyDrafts : this.reload();
                },
                reload: function () {
                    return this.items = lists.surveyDrafs = api.list();
                },
                save: function (item, callback) {
                    if (item.id) {
                        api.update(item, callback);
                    } else {
                        api.save(item, callback);
                    }
                },
                get: function (args, callback) {
                    return api.get(args, callback);
                },
                publish: function () {

                }
            }
        },
        createQuestionApi: function ($scope, id) {
            var custom_methods = {
                list: {
                    method: 'GET',
                    isArray: true
                },
                update: {
                    method: 'PATCH'
                }
            };

            var api = $resource('/api/library_assets/:id', {id: '@id'}, custom_methods);

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


            return apis.question = {
                list: function () {
                    return lists.questions ? lists.questions : this.reload();
                },
                reload: function () {
                    return this.items = lists.questions = api.list(function () {
                        initialize_items(lists.questions);
                        initialize_questions(lists.questions);
                    });
                },
                save: function (item, callback) {
                    if (item.id) {
                        api.update(item, callback);
                    } else {
                        api.save(item, callback);
                    }
                },
                get: function (args, callback) {
                    return api.get(args, callback);
                }
            }
        },
        createTagsApi: function () {
            var customMethods = {
                list: {
                    method: 'GET',
                    isArray: true
                },
                update: {
                    method: 'PATCH'
                }
            };


            var api = apis.tag = $resource('api/tags/:id', {id: '@id'}, customMethods);

            return {
                list: function () {
                    return lists.tags ? lists.tags : this.reload();
                },
                reload: function () {
                    return this.items = lists.tags = api.list(function () {
                        initialize_items(lists.tags);
                    });
                },
                remove: function (id) {
                    var index = _.indexOf(lists.tags, _.filter(lists.tags, function (tag) { return tag.id === id; })[0]);
                    lists.tags.splice(index, 1);
                },
                save: function (item, callback) {
                    if (item.id) {
                        api.update(item, function () {
                            apis.question.reload();
                            $rootScope.$broadcast('questions:reload');
                            if (callback) {
                                callback.apply(this, arguments);
                            }
                        });
                    } else {
                        api.save(item, function (tag) {
                            tag.meta = {};
                            lists.tags.push(tag);
                            if (callback) {
                                callback.apply(this, arguments);
                            }
                        });
                    }
                }
            };
        }
    };
}