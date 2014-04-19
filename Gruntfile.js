module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    requirejs: {
      compile: {
        options: {
            baseUrl: 'jsapp',
            // uglify-minimization/optimization--
            // optimize: 'none',
            stubModules: ['cs'],
            paths: {
                'almond': 'components/almond/almond',
                'jquery': 'components/jquery/dist/jquery.min',
                'backbone': 'build_stubs/backbone',
                'underscore': 'build_stubs/underscore',
                'cs' :'components/require-cs/cs',
                'coffee-script': 'components/require-cs/coffee-script',
                'xlform_view': 'xlform_model_view',
                'xlform_model': 'xlform_model_view'
            },
            name: 'almond',
            include: 'build_configs/dkobo_xlform',
            insertRequire: ['dkobo_xlform'],
            out: 'jsapp/run/dkobo_xlform.js',
            wrap: true,
            exclude: ['coffee-script']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-requirejs');

  grunt.registerTask('default', []);
};
