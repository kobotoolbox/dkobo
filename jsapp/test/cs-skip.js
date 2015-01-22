define('cs', [], function(){
    return {
        load: function(name, req, onload){
        	req([name], function(value){
        		onload(value);
        	});
        }
    };
});
