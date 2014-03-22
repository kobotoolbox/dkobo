// Karma configuration
// Generated on Thu Dec 19 2013 05:42:28 GMT-0300 (CLST)
/*global module*/
'use strict';

module.exports = function(config) {
    config.set({

        // base path, that will be used to resolve files and exclude
        basePath: '',


        // frameworks to use
        frameworks: ['jasmine'],


        // list of files / patterns to load in the browser
        files: [
            '../../../../static/js/angular.js',
            '../../../../static/js/angular-*.js',
            'jasmine/jasmine.js',
            '../controllers/*.js',
            '../directives/*.js',
            '../factories/*.js',
            '../services/*.js',
            'lib/*.js',
            'init.js',
            '../*.js',
            '../../templates/*.html',
            'tests/*.js',
            '../../../../static/js/backbone.js',
            '../../../../static/js/Backbone.Validation.js',
            '../xlform/*.coffee',
            '../xlform/*.js',
            '../xlform/spec/skip_logic.coffee'
        ],


        // list of files to exclude
        exclude: [
            '../xlform/*.backbone.*.js'
        ],


        // test results reporter to use
        // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
        reporters: ['progress', 'coverage'],
        preprocessors: {'../../templates/*.html': 'ng-html2js', '../**/*.coffee': 'coffee'},


        /// https://github.com/vojtajina/ng-directive-testing/commit/7b7a0b8f6b3698868daddc40828da39c3c6b6272#diff-766793014309586429b517112184567d
        /// https://github.com/karma-runner/karma-ng-html2js-preprocessor
        ngHtml2JsPreprocessor: {

            // or define a custom transform function
            cacheIdFromPath: function(filepath) {
                var matches = /^\/(.+\/)*(.+)\.(.+)$/.exec(filepath);

                return 'templates/' + matches[2] + '.' + matches[3];
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
        browsers: ['Chrome', 'Firefox', 'PhantomJS'],


        // If browser does not capture in given timeout [ms], kill it
        captureTimeout: 60000,


        // Continuous Integration mode
        // if true, it capture browsers, run tests and exit
        singleRun: false
    });
};
