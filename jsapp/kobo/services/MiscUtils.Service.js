/*exported MiscUtilsService*/
/*global $*/
/*global log*/
'use strict';

kobo.service('$miscUtils', ['$rootScope', '$userDetails', function ($rootScope, $userDetails) {
    var _this = this,
        _fileUpload,
        _successFn;

    this.confirm = function (message) {
        if (!$userDetails.debug)
            return confirm(message);
        return true;
    };
    this.preventDefault = function (event) {
        event.preventDefault();
    };

    this.bootstrapSurveyUploader = function (callback, which) {
        this.bootstrapFileUploader('.js-import-survey' + (which || ''), callback);
    };

    this.bootstrapQuestionUploader = function (callback) {
        this.bootstrapFileUploader('.js-import-questions', callback);
    };

    this.bootstrapFileUploader = function (selector, callback) {
        callback = callback || function () {};
        _fileUpload = $('.js-import-fileupload' + selector).fileupload({
            headers: {
                "X-CSRFToken": $('meta[name="csrf-token"]').attr('content')
            },
            add: function (e, data) {
                // maybe display some feedback saying the upload is starting...
                $rootScope.isLoading = true;
                $rootScope.add_form = 'Uploading Form';
                $rootScope.$apply();
                log(data.files[0].name + " is uploading...");
                data.submit().success(_successFn)
                .error(function (result) {
                    $rootScope.isLoading = false;
                    $rootScope.add_form = '+ Add Form';
                    $rootScope.$apply();
                    _this.handleXhrError(result);
                }).done(function () {
                    $rootScope.isLoading = false;
                    $rootScope.add_form = '+ Add Form';
                    $rootScope.$apply();
                });
            }
        });
        this.changeFileUploaderSuccess(callback);
    };

    this.changeFileUploaderSuccess = function (successFn) {
        _successFn = successFn
    };

    this.alert = function (message, type, jsonOpts) {
        type = type || 'Information';
        if(!jsonOpts) { jsonOpts = {}; }
        var msgHtml = "<p class='miscutil__alertmessage miscutil__alertmessage--error'>" + message + "</p>";
        var warnings = jsonOpts.warnings || [];
        if(warnings.length > 0) {
            for (var i=0; i<warnings.length; i++) {
                msgHtml += "<p class='miscutil__alertmessage miscutil__alertmessage--warning'>" + warnings[i] + "</p>";
            }
        }
        $('.alert-modal').html(msgHtml).dialog('option', {
            title: type,
            width: 500,
            dialogClass: 'miscutil__alert'
        }).dialog('open');
    };

    this.handleXhrError = function (xhrResult) {
        if(xhrResult.responseJSON && xhrResult.responseJSON.error) {
            _this.alert('Error: ' + xhrResult.responseJSON.error, 'Error', xhrResult.responseJSON);
        } else {
            _this.alert('The server encountered an error: ' + xhrResult.status + ": " + xhrResult.statusText, 'Error');
        }
    };

    this.toggle_response_list = function (item, show) {
        if (item.type !== 'select_one' && item.type !== 'select_all' && item.type !== 'select_multiple') {
            return;
        }

        if (typeof show !== 'undefined') {
            item.meta.show_responses = !show;
        }

        if (item.meta.show_responses) {
            item.meta.show_responses = false;
            item.meta.question_type_class = 'question__type';
            item.meta.question_type_icon = 'fa fa-caret-right';
            item.meta.question_type_icon_class = 'question__type-icon';
        } else {
            item.meta.question_type_class = 'question__type question__type--expanded';
            item.meta.question_type_icon_class = 'question__type-icon question__type--expanded-icon';
            item.meta.question_type_icon = 'fa fa-caret-down';
            item.meta.show_responses = true;
        }
    };
}]);
