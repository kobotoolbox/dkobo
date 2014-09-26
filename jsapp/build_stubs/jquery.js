var global = this;

define('jquery', [], function(){
  if(!global.jQuery) {
    global.process || global.console && global.console.error("jQuery has not been loaded into the page. Library will not work properly.")
  }
  return global.jQuery;
});
