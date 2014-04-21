module.exports = function(grunt) {
  var _ = require('underscore');

  var stubbedPaths = {
    'backbone': 'build_stubs/backbone',
    'underscore': 'build_stubs/underscore',
  };
  var paths = {
    'almond': 'components/almond/almond',
    'jquery': 'components/jquery/dist/jquery.min',
    'cs' :'components/require-cs/cs',
    'backbone': 'components/backbone/backbone',
    'underscore': 'components/underscore/underscore',
    'coffee-script': 'components/require-cs/coffee-script',
  };
  var projectPaths = {
    'xlform_model_view': 'xlform_model_view',
  };

  var mainConfigs = {
    baseUrl: 'jsapp',
    // uglify-minimization/optimization--
    optimize: 'none',
    stubModules: ['cs'],
    paths: paths,
    wrap: true,
    exclude: ['coffee-script'],
  };

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    requirejs: {
      compile_xlform: {
        options: _.extend({}, mainConfigs, {
          name: 'almond',
          include: 'build_configs/dkobo_xlform',
          out: 'jsapp/run/dkobo_xlform.js',
          paths: _.extend({}, paths, projectPaths, stubbedPaths),
        })
      },
    },
    watch: {
      files: ['jsapp/**/*.js', 'jsapp/**/*.coffee'],
      tasks: ['requirejs'],
      options: {
        spawn: false,
      },
    }
  });

  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['watch',]);
};
