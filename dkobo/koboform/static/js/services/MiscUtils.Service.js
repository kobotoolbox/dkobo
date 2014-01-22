/*exported MiscUtilsService*/
/*global $*/
/*global log*/
'use strict';

function MiscUtilsService() {
    var _this = this;

    this.confirm = function (message) {
        return confirm(message);
    };
    this.preventDefault = function (event) {
        event.preventDefault();
    };

    this.bootstrapFileUploader = function ($scope) {
        $(function(){
            $('.btn--header-import').eq(0).fileupload({
                headers: {
                    "X-CSRFToken": $('meta[name="csrf-token"]').attr('content')
                },
                add: function (e, data) {
                    // maybe display some feedback saying the upload is starting...
                    log(data.files[0].name + " is uploading...");
                    data.submit().success(function(result){
                        window.importedSurveyDraft = JSON.parse(result);
                        $scope.updateFormList = true;
                        $scope.$apply();
                    })
                    .error(function (result) {
                        _this.handleXhrError(result);
                    });
                }
            });
        });
    };

    this.alert = function (message) {
        alert(message);
    };

    this.handleXhrError = function (xhrResult) {
        _this.alert('The server encountered an error: ' + xhrResult.status + ": " + xhrResult.statusText);
    };
}