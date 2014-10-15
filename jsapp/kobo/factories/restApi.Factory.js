/* exported restApiFactory */
/* global dkobo_xlform */
'use strict';

function restApiFactory($resource, $timeout) {
    var tags = [
        {questionCount: 0, id: 1, label: 'Demographics' },
        {questionCount: 0, id: 2, label: 'Priorities services' },
        {questionCount: 0, id: 3, label: 'Security' },
        {questionCount: 0, id: 4, label: 'Disputes' },
        {questionCount: 0, id: 5, label: 'Domestic Violence' },
        {questionCount: 0, id: 6, label: 'Mortality' },
        {questionCount: 0, id: 7, label: 'Exposure to War Violence' },
        {questionCount: 0, id: 8, label: 'Former combatants' },
        {questionCount: 0, id: 9, label: 'Victims' },
        {questionCount: 0, id: 10, label: 'Measures for Victims' },
        {questionCount: 1, id: 11, label: 'Monuments' },
        {questionCount: 1, id: 12, label: 'Origins of conflicts' },
        {questionCount: 1, id: 13, label: 'Truth' },
        {questionCount: 1, id: 14, label: 'Information' },
        {questionCount: 1, id: 15, label: 'Accountability' },
        {questionCount: 1, id: 16, label: 'Justice' },
        {questionCount: 1, id: 17, label: 'International Criminal Court' },
        {questionCount: 1, id: 18, label: 'Peace' },
        {questionCount: 1, id: 19, label: 'Group membership'}
    ];
    return {
        createSurveyDraftApi: function (id) {
            if (id === undefined) {
                id = 'new';
            }

            if (id === 'new') {
                return $resource('/api/survey_drafts');
            } else {
                return $resource('/api/survey_drafts/:id', { id: id }, {
                    save: { method: 'PATCH' },
                    publish: { method: 'POST', url: '/api/survey_drafts/:id/publish' }
                });
            }
        },
        createQuestionApi: function ($scope, id) {
            var custom_methods = {
                list: {
                    method: 'GET',
                    isArray: true,
                    transformResponse: function (inputs) {
                        $scope.info_list_items = JSON.parse(inputs);

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

                        for (i = 0; i < $scope.info_list_items.length; i++) {
                            set_defaults($scope.info_list_items[i]);
                        }

                        i = 0;

                        function timed_execution(item) {
                            return $timeout(function () {
                                create_survey(item);
                            }, 10).then(function () {
                                get_props_from_row(item);
                            }).then(function () {
                                i++;
                                if (i < $scope.info_list_items.length) {
                                    timed_execution($scope.info_list_items[i]);
                                }
                            });
                        }

                        if ($scope.info_list_items.length > 0) {
                            timed_execution($scope.info_list_items[i]);
                        }
                        return $scope.items = $scope.info_list_items;
                    }
                }
            };

            if (id !== undefined && id !== 'new') {
                custom_methods.save = {
                    method: 'PATCH'
                };
            } else {
                id = '';
            }
            return $resource('/api/library_assets/:id', {id: id}, custom_methods);
        },
        createTagsApi: function () {
            return {
                list: function () {
                    return tags;
                },
                remove: function (id) {
                    var index = _.indexOf(tags, _.filter(tags, function (tag) { return tag.id === id; })[0]);
                    tags.splice(index, 1);
                }
            }
        }
    };
}