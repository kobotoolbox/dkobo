/*
This file is for any configurations that carry over from karma conf file to the test runner.
*/
if(typeof define === 'undefined') { var define = function (a,b,cb){ module.exports = cb(); } }

define('test/components', [], function(){
    return {
        // used in require.configs({paths:...})
        "dirPaths": {
            "xlform": "xlform_model_view",
        },
        // patterns to serve (used in karma.conf)
        "serve": [
            "xlform_model_view/*.js",
            "xlform_model_view/**/*.js",
            "xlform_model_view/**/*.js",
            "test/**/*.js"
        ],
        // paths to components
        // used in require.configs({paths:...}) and karma.conf
        "libs": {
            "underscore": "components/underscore/underscore.js",
            "jquery": "components/jquery/dist/jquery.js",
            "cs": "test/cs-skip.js",
            "backbone": "components/backbone/backbone.js",
            "backbone-validation": "components/backbone-validation/dist/backbone-validation-amd.js",
        },
        "map": {
          "*": {
            "jquery" : "utils/jquery-private",
            "backbone": "utils/backbone-private"
            },
          "utils/jquery-private": { "jquery": "jquery" },
          "utils/backbone-private": {"backbone": "backbone"},
          "backbone-validation": {"backbone": "backbone"}
        }
    }
});
