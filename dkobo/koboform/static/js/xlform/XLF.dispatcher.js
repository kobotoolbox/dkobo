/* global XLF */
/* global _ */
/* global Backbone */
'use strict';
XLF.dispatcher = (function () {
    var instance = _.clone(Backbone.Events);

    return function () {
        return instance;
    };
} ());