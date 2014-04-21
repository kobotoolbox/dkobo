define('underscore', [], function(){
  if(!this._) {
    console && console.error("Underscore has not been loaded into the page. Library will not work properly.")
  }
  return this._;
});
