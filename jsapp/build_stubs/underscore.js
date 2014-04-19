define('underscore', [], function(){
  if(!window._) {
    console && console.error("Underscore has not been loaded into the page. Library will not work properly.")
  }
  return window._;
});
