define('jquery', [], function(){
  if(!window.jQuery) {
    console && console.error("jQuery has not been loaded into the page. Library will not work properly.")
  }
  return window.jQuery;
});
