// tells the r.js loader to include these modules
require(['cs!xlform/_xlform.init']);

(function(){
  if ( !this.dkobo_xlform ) {
    this.dkobo_xlform = require('cs!xlform/_xlform.init');
  }
})();
