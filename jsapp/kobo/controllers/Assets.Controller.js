/* exported AssetsController */
/* global dkobo_xlform */
/* global _ */
'use strict';
//noinspection JSUnusedGlobalSymbols
kobo.controller('AssetsController', ['$scope', '$rootScope', '$miscUtils', '$api', '$filter', AssetsController]);
function AssetsController($scope, $rootScope, $miscUtils, $api, $filter) {
    $scope.tagFilters = {};
    $rootScope.showImportButton = false;
    $rootScope.showCreateButton = false;
    $scope.questionFilters = {};
    $rootScope.icon_link = 'library/questions';
    $scope.newTagName = '';
    var filter = $filter('itemFilter');
    $scope.tagSorter = {
        criteria: [
            {value: "-date_modified", label: 'Newest'},
            {value: "label", label: 'A - Z'},
            {value: "[count, label]", label: 'A - Z, Empty First'},
            {value: "[-count, label]", label: 'A - Z, Empty Last'},
            {value: '-label', label: 'Z - A'}
        ]
    };

    $scope.tagSorter.selected = $scope.tagSorter.criteria[1];

    $scope.questionSorter = {
        criteria: [
            {value: '-date_modified', label: 'Newest First'},
            {value: 'date_modified', label: 'Oldest First'},
            {value: 'label', label: 'A - Z'},
            {value: '-label', label: 'Z - A'}
        ]
    };

    $scope.questionSorter.selected = $scope.questionSorter.criteria[0];

    $scope.api = $api;

    $api.questions.list();
    $scope.tags = $api.tags.list();

    $miscUtils.bootstrapQuestionUploader(function () {
        $rootScope.$broadcast('reload:library_assets');
    });


    $rootScope.canAddNew = true;
    $rootScope.activeTab = 'Question Library';

    $rootScope.$on('list:library_assets', function () {
        $scope.toggleTagInFilters($api.tags.items);
    });

    $scope.$on('questions:reload', function () {
        $scope.toggleTagInFilters($api.tags.items)
    });

    $scope.toggleTagInFilters = function (items) {
        var tags = _.filter(items, function (item) {
            return item.meta.isSelected;
        });

        $scope.questionFilters.tags = _.pluck(tags, 'label');
        if ($scope.questionFilters.tags.length === 0) {
            delete $scope.questionFilters.tags;
        }
    };

    $scope.getQuestionCount = function () {
        var items = $api.questions.items;
        if (items) {
            return filter(items, $scope.questionFilters).length === items.length ? $api.questions.count : filter(items, $scope.questionFilters).length;
        } else {
            return 0;
        }
    };

    $scope.getCount = function (item) {
        var count = item.count;
        return count + ' question' + (count == 1 ? '' : 's');
    };
}
