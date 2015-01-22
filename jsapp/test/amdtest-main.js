require.config({
  baseUrl: '/base',
  deps: ['test/components'],

  callback: function($components){
      var _c,
          paths = {
              'xlform': 'xlform_model_view',
              'cs': 'test/cs-skip',
          };

      for (_c in $components.libs) {
        paths[_c] = $components.libs[_c].replace(/\.js$/, '');
      }
      for (_c in $components.dirPaths) {
        paths[_c] = $components.dirPaths[_c];
      }
      paths.xlform = "xlform_model_view";

      require.config({
        paths: paths,
        map: {
          "*": { "jquery" : "utils/jquery-private",
                "backbone": "utils/backbone-private",},
          "utils/jquery-private": { "jquery": "jquery" },
          "utils/backbone-private": {"backbone": "backbone"},
          "backbone-validation": {"backbone": "backbone"}
        }
      });

      require(['cs!test/amdrunner'], window.__karma__.start);
  }
});
