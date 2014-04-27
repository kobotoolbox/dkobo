module.exports = function(grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        watch: {
            /** changes to the source files trigger a karma retest
             */
            sourceChanged: {
                files: ['jsapp/kobo/**/*.js', 'jsapp/kobo/**/*.coffee', 'jsapp/kobo/**/*.html'],
                tasks: ['karma:unit:run'],
            },

            /** changes to the tests trigger a karma retest
             */
            testsChanged: {
                files: [
                    // do we want to jump to all coffee tests?
                    'jsapp/test/**/*.js',
                    'jsapp/test/**/*.coffee'
                ],
                tasks: ['karma:unit:run'],
            },

            /** dkobo_xlform.js is build with and AMD packaging module
             *    and is referenced by python and browser.
             *
             *  Changes in the source directory should rebuild the file, which ends up
             *    eventually triggering 'sourceChanged' as well.
             */
            rebuildDkoboXlform: {
                files: ['jsapp/xlform_model_view/**/*.js', 'jsapp/xlform_model_view/**/*.coffee'],
                tasks: ['requirejs:compile_xlform'],
            },

            /** One of the scss files changed, which triggers a rebuild
             *  of the generated css files.
             */
            scssChanged: {
                files: ['jsapp/**/*.scss'],
                tasks: ['buildcss'],
                options: { spawn: false, livereload: false },
            },

            cssChanged: {
                files: ['jsapp/**/*.css'],
                options: { livereload: true },
            }
        },
        karma: {
            unit: {
                configFile: 'jsapp/test/configs/karma.conf.js',
                singleRun: true,
                browsers: ['PhantomJS'],
            },
            travis: {
                configFile: 'jsapp/test/configs/karma.conf.js',
                singleRun: true,
                browsers: ['PhantomJS'],
            },
        },

        requirejs: {
            compile_xlform: {
                options: {
                    baseUrl: 'jsapp',
                    // uglify-minimization/optimization--
                    optimize: 'none',
                    stubModules: ['cs'],
                    wrap: true,
                    exclude: ['coffee-script'],
                    name: 'almond',
                    include: 'build_configs/dkobo_xlform',
                    out: 'jsapp/kobo.compiled/dkobo_xlform.js',
                    paths: {
                        'almond': 'components/almond/almond',
                        'jquery': 'components/jquery/dist/jquery.min',
                        'cs' :'components/require-cs/cs',
                        // stubbed paths for almond build
                        'backbone': 'build_stubs/backbone',
                        'underscore': 'build_stubs/underscore',
                        // 'backbone': 'components/backbone/backbone',
                        // 'underscore': 'components/underscore/underscore',
                        'coffee-script': 'components/require-cs/coffee-script',
                        // project paths
                        'xlform_model_view': 'xlform_model_view',
                    },
                },
            },
        },

        sass: {
            dist: {
                options: {
                    style: 'compact',
                },
                files: {
                    // scss does not get rid of duplicate rules and the style_modules has lots
                    // of duplicates so we must use cssmin afterwards.
                    'jsapp/kobo.compiled/kobo.verbose.css' : 'jsapp/kobo/kobo.scss',
                },
            },
        },
        cssmin: {
            dist: {
                options: {
                    banner: "/* compiled from 'kobo/kobo.scss' and 'kobo/style_modules' */",
                    report: ['min', 'gzip'],
                    keepBreaks: true,
                },
                files: {
                    'jsapp/kobo.compiled/kobo.css': ['jsapp/kobo.compiled/kobo.verbose.css'],
                },
            },
        },
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-karma');
    grunt.loadNpmTasks('grunt-contrib-requirejs');
    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-cssmin');

    grunt.registerTask('build', [
        'requirejs:compile_xlform',
        'buildcss',
    ]);

    grunt.registerTask('buildcss', [
        'sass:dist',
        'cssmin:dist',
    ]);

    grunt.registerTask('test', [
        'build',
        'karma:travis',
    ]);
    grunt.registerTask('default', [
        'requirejs:compile_xlform',
        'buildcss',
        'watch',
    ]);
};

/*
http://stackoverflow.com/questions/22319397/running-yeoman-angular-generator-karma-dependency-error
npm install karma@0.11.14 grunt-karma@0.7.2

'karma-junit-reporter',
'karma-chrome-launcher',
'karma-firefox-launcher',
'karma-phantomjs-launcher',
*/