/* this file will return jQuery with various plugins.
*  since not all the plugins are AMD installable (as needed in tests), it mocks plugins of UI-related
*  functionality unless jQuery is already defined in the global scope.
*/
if (this.jQuery) {
    var _existingJq = this.jQuery;
    define([], function(){
        return _existingJq;
    });
} else {
    define(['jquery'], function(jq){
        jq.scrollTo = function(){ console.error('faked scrollTo in jquery-private.js'); };
        jq.fn.sortable = function(){ console.error('faked sortable in jquery-private.js'); };
        jq.fn.select2 = function(){ console.error('faked select2 in jquery-private.js'); };
        return jq.noConflict();
    });
}
