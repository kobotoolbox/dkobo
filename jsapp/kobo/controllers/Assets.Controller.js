/* exported AssetsController */
/* global dkobo_xlform */
/* global _ */
'use strict';
function AssetsController($scope, $rootScope, $resource, $restApi, $timeout, $filter, $miscUtils) {
    var assets = $restApi.create_question_api($scope);
    $scope.sort_criteria = '-date_modified';
    $scope.tagsSortCriteria = '-date_modified';
    $scope.tagFilters = {};
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    $scope.filters = {};
    $rootScope.icon_link = 'library/questions';

    assets.list();

    $miscUtils.bootstrapQuestionUploader(assets.list);

    $scope.select_all = null;

    function select_all() {
        var new_class = $scope.select_all ? 'questions__question--selected' : '';
        var filter = $filter('filter');

        if (!$scope.is_updating_select_all) {
            _.each($scope.info_list_items, function (item) {
                item.meta.is_selected = false;
                item.meta.additionalClasses = '';
            });

            _.each(filter($scope.info_list_items, $scope.filters), function (item) {
                item.meta.is_selected = $scope.select_all;
                item.meta.additionalClasses = new_class;
            });
        }

        $scope.is_updating_select_all = false;
    }

    $scope.delete_selected = function () {
        if (!$miscUtils.confirm('are you sure you want to delete ' + $scope.get_selected_amount() + '?')) {
            return;
        }
        _.each($scope.info_list_items, function (item) {
            if (item.meta.is_selected) {
                assets.remove({id: item.id});
            }
        });

        $scope.info_list_items = _.filter($scope.info_list_items, function (item) {
            return !item.meta.is_selected
        });
    };

    $scope.$watch('filters.label', function () {
        select_all();
    });

    $scope.$watch('select_all', function () {
        if ($scope.select_all === null) {
            return;
        }
        select_all();
    });

    $scope.$watch('show_responses', function () {
        if (typeof $scope.show_responses === 'undefined') {
            return;
        }

        _.each($scope.info_list_items, function (item) {
            $miscUtils.toggle_response_list(item);
        });
    });

    $scope.get_selected_count = function () {
        return _.filter($scope.info_list_items, function (item) {
            return item.meta ? item.meta.is_selected : false;
        }).length;
    };

    $scope.get_selected_amount = function () {
        var amount = $scope.get_selected_count();

        if (amount > 1 || amount === 0) {
            return amount + ' questions';
        } else {
            return amount + ' question';
        }
    };

    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Question Library';

    $scope.tags = [
        {questionCount: 0, id: -1, label: 'Demographics', meta: {isSelected: true, additionalClasses: 'tags__tag--selected'} },
        {questionCount: 0, id: -1, label: 'Priorities services' },
        {questionCount: 0, id: -1, label: 'Security', meta: {isSelected: true, additionalClasses: 'tags__tag--selected'} },
        {questionCount: 0, id: -1, label: 'Disputes' },
        {questionCount: 0, id: -1, label: 'Domestic Violence' },
        {questionCount: 0, id: -1, label: 'Mortality' },
        {questionCount: 0, id: -1, label: 'Exposure to War Violence' },
        {questionCount: 0, id: -1, label: 'Former combatants' },
        {questionCount: 0, id: -1, label: 'Victims' },
        {questionCount: 0, id: -1, label: 'Measures for Victims' },
        {questionCount: 1, id: -1, label: 'Monuments' },
        {questionCount: 1, id: -1, label: 'Origins of conflicts' },
        {questionCount: 1, id: -1, label: 'Truth' },
        {questionCount: 1, id: -1, label: 'Information' },
        {questionCount: 1, id: -1, label: 'Accountability' },
        {questionCount: 1, id: -1, label: 'Justice' },
        {questionCount: 1, id: -1, label: 'International Criminal Court' },
        {questionCount: 1, id: -1, label: 'Peace' },
        {questionCount: 1, id: -1, label: 'Group membership'}
    ];

    function initialize_tags() {
        _.each($scope.tags, function (tag) {
            if (typeof tag.meta === 'undefined') {
                tag.meta = {};
            }
        });
    }

    initialize_tags();

    $scope.toggleTagInFilters = function (item) {
        if (!$scope.filters.tags) {
            $scope.filters.tags = [];
        }
        var tags = $scope.filters.tags;

        if (item.meta.isSelected) {
            tags.push({id: item.id});
        } else {
            tags.splice(_.indexOf(tags, _.filter(tags, function (tag) { tag.id === item.id })), 1);
        }

        if (tags.length === 0) {
            delete $scope.filters.tags;
        }
    };
}
