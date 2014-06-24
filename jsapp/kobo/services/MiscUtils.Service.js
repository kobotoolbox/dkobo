/*exported MiscUtilsService*/
/*global $*/
/*global log*/
'use strict';

function MiscUtilsService($rootScope) {
    var _this = this,
        _fileUpload,
        _successFn;

    this.confirm = function (message) {
        return confirm(message);
    };
    this.preventDefault = function (event) {
        event.preventDefault();
    };

    this.bootstrapFileUploader = function () {
        _fileUpload = $('.js-import-fileupload').eq(0).fileupload({
            headers: {
                "X-CSRFToken": $('meta[name="csrf-token"]').attr('content')
            },
            add: function (e, data) {
                // maybe display some feedback saying the upload is starting...
                $rootScope.isLoading = true;
                $rootScope.$apply();
                log(data.files[0].name + " is uploading...");
                data.submit().success(_successFn)
                .error(function (result) {
                    $rootScope.isLoading = false;
                    $rootScope.$apply();
                    _this.handleXhrError(result);
                }).done(function () {
                    $rootScope.isLoading = false;
                    $rootScope.$apply();
                });
            }
        });
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