module.exports = function(config) {
    var path = require('path');

    config.set({
        basePath: path.resolve(__dirname, '../..'),
        frameworks: ['jasmine'],
        files: [],
        exclude: [],
        // test results reporters: (dots|progress|junit|growl|coverage)
        reporters: ['progress', 'coverage'],
        preprocessors: {
          '../*/*.js': ['coverage'],
          '../../templates/*.html': 'ng-html2js',
          '../**/*.coffee': 'coffee'
        },
        /// https://github.com/vojtajina/ng-directive-testing/commit/7b7a0b8f6b3698868daddc40828da39c3c6b6272#diff-766793014309586429b517112184567d
        /// https://github.com/karma-runner/karma-ng-html2js-preprocessor
        ngHtml2JsPreprocessor: {
            cacheIdFromPath: function(filepath) {
                var matches = /^\/(.+\/)*(.+)\.(.+)$/.exec(filepath);
                return 'templates/' + matches[2] + '.' + matches[3];
            }
        },
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,
        browsers: ['Chrome', 'PhantomJS'],
        captureTimeout: 60000,
        singleRun: false,
    });
};
