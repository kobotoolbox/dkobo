// Karma configuration
// Generated on Thu Dec 19 2013 05:42:28 GMT-0300 (CLST)
/*global module*/
'use strict';

var dkoboDirs = {
    projStatic: '../dkobo/static',
    sut: '../dkobo/koboform/static/js/sut',
    js: '../dkobo/koboform/static/js',
    staticTemplates: '../dkobo/koboform/static/templates'
};

module.exports = function(config) {
    config.set({

        // base path, that will be used to resolve files and exclude
        basePath: '',


        // frameworks to use
        frameworks: ['jasmine'],


        // list of files / patterns to load in the browser
        files: [
            dkoboDirs.projStatic + '/js/angular.js',
            dkoboDirs.projStatic + '/js/angular-*.js',
            dkoboDirs.projStatic + '/js/underscore.js',
            dkoboDirs.projStatic + '/js/jquery-1.10.2.js',
            dkoboDirs.projStatic + '/js/jquery-migrate-1.2.1.js',
            dkoboDirs.projStatic + '/js/jquery-ui-1.10.3.custom.js',
            dkoboDirs.projStatic + '/js/select2.min.js',
            dkoboDirs.projStatic + '/js/backbone.js',
            dkoboDirs.projStatic + '/js/Backbone.Validation.js',
            dkoboDirs.projStatic + '/js/jquery.poshytip.js',
            dkoboDirs.projStatic + '/js/jquery-editable-poshytip.js',
            dkoboDirs.sut + '/lib/init.js',
            dkoboDirs.sut + '/jasmine/jasmine.js',
            dkoboDirs.js + '/controllers/*.js',
            dkoboDirs.js + '/directives/*.js',
            dkoboDirs.js + '/factories/*.js',
            dkoboDirs.js + '/services/*.js',
            dkoboDirs.js + '/*.js',
            dkoboDirs.js + '/csv.coffee',
            dkoboDirs.js + '/xlform/*.coffee',
            dkoboDirs.js + '/xlform/validator.js',
            dkoboDirs.js + '/xlform/validator.backbone.adapters.js',
            dkoboDirs.js + '/xlform/XLF.skipLogicParser.js',
            dkoboDirs.staticTemplates + '/*.html',
            dkoboDirs.sut + '/lib/sinon.js',
            dkoboDirs.js + '/xlform/spec/spec.coffee',
            dkoboDirs.sut + '/tests/*.js',
        ],


        // list of files to exclude
        exclude: [
            '../xlform/*.backbone.*.js'
        ],


        // test results reporter to use
        // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
        reporters: ['progress'],
        preprocessors: {
            '../*/*.js': ['coverage'],
            '../dkobo/koboform/static/templates/*.html': 'ng-html2js',
            '../**/*.coffee': 'coffee'
        },


        /// https://github.com/vojtajina/ng-directive-testing/commit/7b7a0b8f6b3698868daddc40828da39c3c6b6272#diff-766793014309586429b517112184567d
        /// https://github.com/karma-runner/karma-ng-html2js-preprocessor
        ngHtml2JsPreprocessor: {

            // or define a custom transform function
            cacheIdFromPath: function(filepath) {
                var matches = /^\/(.+\/)*(.+)\.(.+)$/.exec(filepath);

                return 'templates/' + matches[2] + '.' + matches[3];
            }
        },

        coffeePreprocessor: {
            // options passed to the coffee compiler
            options: {
                bare: true,
                sourceMap: false
            },
            // transforming the filenames
            transformPath: function(path) {
                return path.replace(/\.coffee$/, '.coffee-karma.js');
            }
        },
        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // Start these browsers, currently available:
        // - Chrome
        // - ChromeCanary
        // - Firefox
        // - Opera (has to be installed with `npm install karma-opera-launcher`)
        // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
        // - PhantomJS
        // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
        browsers: ['Chrome'],

        // If browser does not capture in given timeout [ms], kill it
        captureTimeout: 60000,


        // Continuous Integration mode
        // if true, it capture browsers, run tests and exit
        singleRun: false
    });
};
