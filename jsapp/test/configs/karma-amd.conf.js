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
        componentFiles = [
            project('test/components.js', 0, 0, 1),
            project('test/unit/xlform/**/*.js', 0, 0, 1),
            project('test/**/*.js.map', 0, 0, 1),
            project('utils/*-private.js', 0, 0, 1),
            project('test/**/*.coffee', 0, 0, 1),
            project('test/amdtest-main.js', 1, 0, 1),
        ],
        components = require(path.resolve(__dirname, '../components.js'));

    for (var _c in components.libs) {
        if (_c !== "cs") {
            componentFiles.push(project(components.libs[_c], 0, 1, 1));
        } else {
            componentFiles.push(project('test/cs-skip.js', 1, 0, 1));
        }
    }

    for (_c in components.serve) {
        componentFiles.push(project(components.serve[_c], 0, 1, 1));
    }

    componentFiles.push(project('test/amdrunner.js', 0, 1, 1));

    config.set({
        basePath: path.resolve(__dirname, '../..'),
        frameworks: ['jasmine', 'requirejs'],
        files: componentFiles,
        plugins: [
            // jasmine + reporters
            'karma-requirejs',
            'karma-coverage',
            'karma-jasmine',
            'karma-junit-reporter',
            'karma-growl-reporter',

            // browser launchers
            'karma-phantomjs-launcher',
            'karma-chrome-launcher',
            'karma-firefox-launcher',
        ],
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: false,
        captureTimeout: 60000,
        browserNoActivityTimeout: 60000,
    });
};
