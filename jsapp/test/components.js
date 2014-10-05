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
        "nodeStubs": {
            "jquery": "build_stubs/jquery",
        },
        // patterns to serve (used in karma.conf)
        "serve": [
            "test/fixtures/*.coffee",
            "xlform_model_view/*.js",
            "xlform_model_view/*.coffee",
            "test/unit/SkipLogic.Tests.coffee",
            "test/unit/xlform/**/*.coffee"
        ],
        // paths to components
        // used in require.configs({paths:...}) and karma.conf
        "libs": {
            "underscore": "components/underscore/underscore.js",
            "jquery": "components/jquery/dist/jquery.js",
            "cs": "components/require-cs/cs.js",
            "sinon": "components/sinon/index.js",
            "jasmine-sinon": "components/jasmine-sinon/lib/jasmine-sinon.js",
            "coffee-script": "components/require-cs/coffee-script.js",
            "backbone": "components/backbone/backbone.js",
            "backbone-validation": "components/backbone-validation/dist/backbone-validation-amd.js",
        }
    };
});
