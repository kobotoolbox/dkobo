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
            $('.js-import-fileupload').eq(0).fileupload({
                headers: {
                    "X-CSRFToken": $('meta[name="csrf-token"]').attr('content')
                },
                add: function (e, data) {
                    // maybe display some feedback saying the upload is starting...
                    $scope.isLoading = true;
                    $scope.$apply();
                    log(data.files[0].name + " is uploading...");
                    data.submit().success(function(result){
                        window.importedSurveyDraft = result;
                        $scope.updateFormList();
                    })
                    .error(function (result) {
                        $scope.isLoading = false;
                        $scope.$apply();
                        _this.handleXhrError(result);
                    }).done(function () {
                        $scope.isLoading = false;
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