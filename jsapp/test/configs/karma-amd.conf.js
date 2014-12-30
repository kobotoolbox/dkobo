module.exports = function(config) {
    var path = require('path');
    function project(pattern, included, watched, served) {
        if(included === undefined) { included = false; }
        if(watched === undefined) { watched = false; }
        if(served === undefined) { served = true; }
        return {
            pattern: pattern,
            included: !!included,
            watched: !!watched,
            served: !!served
        };
    }

    var _c,
        componentFiles = [],
        components = require(path.resolve(__dirname, '../components.js'));

    for (var _c in components.libs) {
        componentFiles.push(project(components.libs[_c], 0, 1, 1));
    }
    for (_c in components.serve) {
        componentFiles.push(project(components.serve[_c], 0, 1, 1));
    }

    config.set({
        basePath: path.resolve(__dirname, '../..'),
        frameworks: ['jasmine', 'requirejs', 'sinon'],
        files: componentFiles.concat([
            project('test/components.js', 0, 0, 1),
            project('test/amdrunner.coffee', 0, 1, 1),
            'test/amdtest-main.js',
        ]),
        plugins: [
            // jasmine + reporters
            'karma-jasmine',
            'karma-coverage',
            'karma-requirejs',
            'karma-junit-reporter',
            'karma-growl-reporter',
            'karma-sinon',

            // browser launchers
            'karma-phantomjs-launcher',
            'karma-chrome-launcher',
            'karma-firefox-launcher',

            // preprocessors
            'karma-ng-html2js-preprocessor',
        ],
        // exclude: [],
        // test results reporters: (dots|progress|junit|growl|coverage)
        reporters: ['progress', 'coverage'],
        preprocessors: {
          // '../**/*.js': ['coverage'],
          '**/*.html': 'ng-html2js',
        },

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
        autoWatch: false,
        browsers: ['PhantomJS'],
        captureTimeout: 60000,
        browserNoActivityTimeout: 60000,
        singleRun: true,
    });
};
