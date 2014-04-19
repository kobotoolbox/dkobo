define('dkobo_xlform', ['cs!xlform_model/model', 'cs!xlform_views/view'], function(model, view){
  var XLF = {
    view: view,
    model: model
  };
  if (!window.dkobo_xlform) {
    window.dkobo_xlform = XLF;
  }
});
