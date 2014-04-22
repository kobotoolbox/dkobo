module.exports = function(config) {
    var path = require('path');

    config.set({
        basePath: path.resolve(__dirname, '../..'),
        frameworks: ['jasmine'],
        files: [
            // angular
            'components/angular/angular.js',
            // formerly: '../dkobo/static/js/angular-*.js',
            'components/angular-cookies/angular-cookies.js',
            'components/angular-mocks/angular-mocks.js',
            'components/angular-resource/angular-resource.js',
            'components/angular-route/angular-route.js',

            // formerly contents of 'sut/lib/*.js',
            'components/sinonjs/sinon.js',
            'components/jasmine-sinon/lib/jasmine-sinon.js',
            'components/underscore/underscore.js',
            'components/backbone/backbone.js',

            // kobo jsapp source files
            'kobo/**/*.js',
            'kobo/**/*.coffee',
            'kobo/**/*.html',

            // kobo jsapp compiled files
            'kobo.compiled/**/*.js',
            'kobo.compiled/**/*.html',

            // jsapp/test files
            'test/**/*.js',
            'test/**/*.coffee',
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
                return path.replace(/\.coffee$/, '.karma.js');
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
