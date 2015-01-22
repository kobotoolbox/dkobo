define(['jquery'], function(jq){
	jq.scrollTo = function(){ console.error('faked scrollTo in jquery-private.js'); };
	jq.fn.sortable = function(){ console.error('faked sortable in jquery-private.js'); };
	jq.fn.select2 = function(){ console.error('faked select2 in jquery-private.js'); };
	return jq.noConflict();
});