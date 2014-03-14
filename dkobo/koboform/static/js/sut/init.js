/*exported staticFilesUri*/
/* exported viewUtils */
var staticFilesUri = '';
var viewUtils = {};
var XLF = {};


sinon.stubObject = function (obj, target) {
    var cls = (typeof obj == 'function') ? obj.prototype : obj;
    target = target || {};

    Object.getOwnPropertyNames(cls).filter(function(p){
        return typeof cls[p] == 'function';
    }).forEach(function(p) { target[p] = sinon.stub() });

    return cls.__proto__ ? stub(cls.__proto__, target) : target;
};