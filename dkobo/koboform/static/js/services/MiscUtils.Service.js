/*exported MiscUtilsService*/
'use strict';

function MiscUtilsService() {
    this.confirm = function (message) {
        return confirm(message);
    };
    this.preventDefault = function (event) {
        event.preventDefault();
    };
}