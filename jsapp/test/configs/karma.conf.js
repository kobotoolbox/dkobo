module.exports = function(config) {
    var path = require('path');

    config.set({
        basePath: path.resolve(__dirname, '../..'),
        frameworks: ['jasmine'],
        files: [
            // angular
            'components/angular/angular.js',
            'components/angular-cookies/angular-cookies.js',
            'components/angular-mocks/angular-mocks.js',
            'components/angular-resource/angular-resource.js',
            'components/angular-route/angular-route.js',
            'components/angular-ui-utils/ui-utils.js',

            'components/sinon/index.js',
            'components/jasmine-sinon/lib/jasmine-sinon.js',

            'components/jquery/dist/jquery.js',
            'components/lodash/dist/lodash.js',
            'components/backbone/backbone.js',
            // require-js
            'components/requirejs/require.js',
            {pattern: 'components/require-cs/*.js', served: true, included: false, watched: false},

            '../dkobo/static/js/Backbone.Validation.js',

            // require-js
            'components/requirejs/require.js',
            'components/angular-ui-select/dist/select.js',
            'components/angular-sanitize/angular-sanitize.min.js',
            {pattern: 'components/require-cs/cs.js', watched: false, served: true, included: false},
            {pattern: 'components/require-cs/coffee-script.js', watched: false, served: true, included: false},
            {pattern: 'components/backbone-validation/dist/backbone-validation-amd.js', watched: false, served: true, included: false},

            'test/init.js',

            // kobo jsapp source files
            'kobo/**/*.html',
            'kobo/**/*.js',
            'kobo/controllers/*.js',
            'kobo/factories/*.js',
            'kobo/filters/*.js',
            'kobo/services/*.js',
            'kobo/directives/*.js',

            // kobo jsapp compiled files
            'kobo.compiled/**/*.js',
            // 'kobo.compiled/**/*.html',

            // jsapp/test files
            'test/unit/Controller/*.coffee',
            'test/unit/Directive/*.coffee',
            'test/unit/Factory/*.coffee',
            'test/unit/Service/*.coffee',
            'test/unit/SkipLogic/*.coffee',
            'test/unit/Validator/*.coffee',
            'test/unit/SkipLogic.Tests.coffee',
            'test/unit/Xlform.Tests.coffee',
            'test/runner.coffee',
        ],
        plugins: [
            // jasmine + reporters
            'karma-jasmine',
            'karma-coverage',
            'karma-junit-reporter',
            'karma-growl-reporter',

            // browser launchers
            'karma-phantomjs-launcher',
            'karma-chrome-launcher',
            'karma-firefox-launcher',

            // preprocessors
            'karma-coffee-preprocessor',
            'karma-ng-html2js-preprocessor',
        ],
        // exclude: [],
        // test results reporters: (dots|progress|junit|growl|coverage)
        reporters: ['progress', 'coverage'],
        preprocessors: {
          // '../**/*.js': ['coverage'],
          '**/*.html': 'ng-html2js',
          '**/*.coffee': ['coffee'],
        },
        coffeePreprocessor: {
            options: {
                bare: true,
                sourceMap: false
            },
            transformPath: function(path) {
                return path.replace(/\.coffee$/, '.coffee-karma.js');
            },
        },
        /// https://github.com/vojtajina/ng-directive-testing/commit/7b7a0b8f6b3698868daddc40828da39c3c6b6272#diff-766793014309586429b517112184567d
        /// https://github.com/karma-runner/karma-ng-html2js-preprocessor
        ngHtml2JsPreprocessor: {
            cacheIdFromPath: function(filepath) {
                var matches = /^\/?(.+\/)*(.+)\.(.+)$/.exec(filepath);
                return 'templates/' + matches[2] + '.' + matches[3];
            }
        },

        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,
        // browsers: ['PhantomJS', 'Chrome'],
        browsers: ['PhantomJS'],
        captureTimeout: 60000,
        singleRun: false,
    });
};
