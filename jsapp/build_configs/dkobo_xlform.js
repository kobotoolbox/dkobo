// tells the r.js loader to include these modules
require(['cs!xlform_model_view/model', 'cs!xlform_model_view/view']);

(function(){
  if ( !this.dkobo_xlform ) {
    this.dkobo_xlform = {
      view: require('cs!xlform_model_view/view'),
      model: require('cs!xlform_model_view/model')
    };
  }
})();
