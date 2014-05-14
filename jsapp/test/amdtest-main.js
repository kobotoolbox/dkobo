require.config({
  baseUrl: '/base',
  deps: ['test/components'],
  callback: function($components){
      var _c,
          paths = {
              'xlform': 'xlform_model_view'
          };

      for (_c in $components.libs) {
          paths[_c] = $components.libs[_c].replace(/\.js$/, '');
      }
      for (_c in $components.dirPaths) {
          paths[_c] = $components.dirPaths[_c];
      }

      require.config({ paths: paths });
      require(['cs!test/amdrunner'], window.__karma__.start);
  }
});
