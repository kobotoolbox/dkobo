/* exported restApiFactory */
'use strict';

function restApiFactory($resource, $timeout) {
    return {
        createSurveyDraftApi: function (id) {
            var customMethods = {};
            if (id === 'new') {
                return $resource('/api/survey_drafts', {}, {
                    save: { method: 'POST' }
                });
            } else {
                return $resource('/api/survey_drafts/:id', { id: id }, {
                    save: { method: 'PATCH' }
                });
            }

        },
        create_question_api: function ($scope) {
            var custom_methods = {
                list: {
                    method: 'GET',
                    isArray: true,
                    transformResponse: function (inputs) {
                        $scope.info_list_items = JSON.parse(inputs);

                        function create_survey(item) {
                            item.backbone_model = XLF.createSurveyFromCsv(item.body);
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
                                item.label = row.getValue('label');
                                item.type = row.get("type").get("typeId");

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


                        function timed_execution(item) {
                            return $timeout(function () {
                                set_defaults(item);
                            }, 50).then(function () {
                                create_survey(item);
                            }).then(function () {
                                get_props_from_row(item);
                            }).then(function () {
                                i++;
                                if (i < $scope.info_list_items.length) {
                                    timed_execution($scope.info_list_items[i]);
                                }
                            });
                        }

                        timed_execution($scope.info_list_items[i]);

                    }
                }
            }
            return $resource('/api/library_assets', null, custom_methods);
        }
    };
}