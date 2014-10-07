/*exported MiscUtilsService*/
/*global $*/
/*global log*/
'use strict';

function MiscUtilsService($rootScope, $userDetails) {
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
    }

    this.alert = function (message, type) {
        type = type || 'Information';
        $('.alert-modal').html(message).dialog('option', {
            title: type,
            width: 500
        }).dialog('open');
    };

    this.handleXhrError = function (xhrResult) {
        if(xhrResult.responseJSON && xhrResult.responseJSON.error) {
            _this.alert('Error: ' + xhrResult.responseJSON.error, 'Error');
        } else {
            _this.alert('The server encountered an error: ' + xhrResult.status + ": " + xhrResult.statusText, 'Error');
        }
    };
}