/*exported AssetsController*/
'use strict';
function AssetsController($scope, $rootScope, $resource, $restApi) {
    var assets = $restApi.create_question_api();

    assets.query(function (results) {

        for (var i = 0; i < results.length; i++) {
            results[i].meta = {
                show_responses: false,
                is_selected: false,
                question_class: 'questions__question',
                question_type_class: 'question__type',
                question_type_icon: 'fa fa-caret-right',
                question_type_icon_class: 'question__type-icon'
            }
        }

        // for demo purposes

        results[2].meta.question_class = 'questions__question questions__question--selected';
        results[2].meta.is_selected = true;

        results[3].meta.question_type_class = 'question__type question__type--expanded';
        results[3].meta.question_type_icon_class = 'question__type-icon question__type--expanded-icon';
        results[3].meta.question_type_icon = 'fa fa-caret-down';
        results[3].meta.show_responses = true;

        $scope.info_list_items = results;
    });

    $scope.toggle_response_list = function (item) {
        if (item.meta.show_responses) {
            item.meta.show_responses = false;
            item.meta.question_type_class = 'question__type'
            item.meta.question_type_icon = 'fa fa-caret-right'
            item.meta.question_type_icon_class = 'question__type-icon'
        } else {
            item.meta.question_type_class = 'question__type question__type--expanded';
            item.meta.question_type_icon_class = 'question__type-icon question__type--expanded-icon';
            item.meta.question_type_icon = 'fa fa-caret-down';
            item.meta.show_responses = true;
        }
    }

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Question Library';
}